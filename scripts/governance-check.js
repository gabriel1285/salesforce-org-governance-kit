#!/usr/bin/env node
/*
 * Governance check: fails the PR when metadata breaks the org's rules.
 * No dependencies, runs in a second, before any org is touched.
 *
 * Rules
 *   VR-BYPASS     Every validation rule checks $Permission.Bypass_Validation_Rules.
 *   FLOW-BYPASS   Every record-triggered flow checks $Permission.Bypass_Automation in its entry formula.
 *   FLOW-FAULT    Every DML or action element in a flow has a fault path
 *                 (the logger subflow itself is exempt).
 *   FLOW-HARDCODE No hard-coded 15/18-character Salesforce Ids in flows.
 *   PERM-POWER    No permission set grants Modify All Data, View All Data, Manage Users
 *                 or Customize Application, and no object-level Modify All.
 *   PERM-BYPASS   Bypass custom permissions are granted only by Automation_Admin.
 *   NO-PROFILES   Access lives in permission sets: no profile metadata in the repo.
 *   DESCRIPTION   Flows, validation rules, fields and permission sets have a description, and it
 *                 fits the platform limit (255 for validation rules and permission sets, 1000 for
 *                 fields). An over-long description passes source conversion but fails the deploy.
 */
'use strict';

const fs = require('fs');
const path = require('path');

const ROOT = process.cwd();
const project = JSON.parse(fs.readFileSync(path.join(ROOT, 'sfdx-project.json'), 'utf8'));
const packageDirs = project.packageDirectories.map((d) => d.path);

const BYPASS_GRANTER = 'Automation_Admin';
const LOGGER_FLOW = 'Subflow_Log_Automation_Error';
const POWER_PERMS = ['ModifyAllData', 'ViewAllData', 'ManageUsers', 'CustomizeApplication'];
const BYPASS_PERMS = ['Bypass_Automation', 'Bypass_Validation_Rules'];

const findings = [];
const fail = (rule, file, msg) => findings.push({ rule, file: path.relative(ROOT, file), msg });

// Description present and, where the platform caps it, within the limit.
function checkDescription(file, xml, what, maxLength) {
  const text = tag(xml, 'description');
  if (!text) return fail('DESCRIPTION', file, `${what} has no description.`);
  const length = decodeXml(text).length;
  if (maxLength && length > maxLength) {
    fail('DESCRIPTION', file, `${what} description is ${length} characters, longer than the ${maxLength} the platform accepts.`);
  }
}

function decodeXml(s) {
  return s.replace(/&lt;/g, '<').replace(/&gt;/g, '>').replace(/&quot;/g, '"').replace(/&apos;/g, "'").replace(/&amp;/g, '&');
}

function walk(dir, out = []) {
  if (!fs.existsSync(dir)) return out;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(full, out);
    else out.push(full);
  }
  return out;
}

const tag = (xml, name) => {
  const m = xml.match(new RegExp(`<${name}>([\\s\\S]*?)</${name}>`));
  return m ? m[1].trim() : null;
};
const blocks = (xml, name) => xml.match(new RegExp(`<${name}>[\\s\\S]*?</${name}>`, 'g')) || [];

const files = packageDirs.flatMap((d) => walk(path.join(ROOT, d)));

for (const file of files) {
  const xml = file.endsWith('.xml') ? fs.readFileSync(file, 'utf8') : '';
  const base = path.basename(file);

  if (file.split(path.sep).includes('profiles')) {
    fail('NO-PROFILES', file, 'Profile metadata found. Grant access through permission sets instead.');
    continue;
  }

  if (base.endsWith('.validationRule-meta.xml')) {
    const formula = tag(xml, 'errorConditionFormula') || '';
    if (!formula.includes('$Permission.Bypass_Validation_Rules')) {
      fail('VR-BYPASS', file, 'Validation rule does not check $Permission.Bypass_Validation_Rules.');
    }
    checkDescription(file, xml, 'Validation rule', 255);
  }

  if (base.endsWith('.field-meta.xml')) {
    checkDescription(file, xml, 'Field', 1000);
  }

  if (base.endsWith('.flow-meta.xml')) {
    const flowName = base.replace('.flow-meta.xml', '');
    checkDescription(file, xml, 'Flow');

    const start = tag(xml, 'start') || '';
    const triggerType = tag(start, 'triggerType');
    if (triggerType && triggerType.startsWith('Record')) {
      const entry = tag(start, 'filterFormula') || '';
      if (!entry.includes('$Permission.Bypass_Automation')) {
        fail('FLOW-BYPASS', file, 'Record-triggered flow does not check $Permission.Bypass_Automation in its entry formula.');
      }
    }

    if (flowName !== LOGGER_FLOW) {
      for (const kind of ['recordCreates', 'recordUpdates', 'recordDeletes', 'actionCalls']) {
        for (const el of blocks(xml, kind)) {
          if (!el.includes('<faultConnector>')) {
            fail('FLOW-FAULT', file, `${kind} element "${tag(el, 'name')}" has no fault path.`);
          }
        }
      }
    }

    // Salesforce Ids: 3-char key prefix, 2-char instance, then '0', 15 or 18 chars in total.
    const ids = xml.match(/<stringValue>[a-zA-Z0-9]{5}0[a-zA-Z0-9]{9}([a-zA-Z0-9]{3})?<\/stringValue>/g);
    if (ids) fail('FLOW-HARDCODE', file, `Possible hard-coded Id(s): ${ids.join(', ')}`);
  }

  if (base.endsWith('.permissionset-meta.xml')) {
    const psName = base.replace('.permissionset-meta.xml', '');
    checkDescription(file, xml, 'Permission set', 255);

    for (const up of blocks(xml, 'userPermissions')) {
      const name = tag(up, 'name');
      if (tag(up, 'enabled') === 'true' && POWER_PERMS.includes(name)) {
        fail('PERM-POWER', file, `Grants system permission ${name}.`);
      }
    }
    for (const op of blocks(xml, 'objectPermissions')) {
      if (tag(op, 'modifyAllRecords') === 'true') {
        fail('PERM-POWER', file, `Grants Modify All on ${tag(op, 'object')}.`);
      }
    }
    for (const cp of blocks(xml, 'customPermissions')) {
      if (tag(cp, 'enabled') === 'true' && BYPASS_PERMS.includes(tag(cp, 'name')) && psName !== BYPASS_GRANTER) {
        fail('PERM-BYPASS', file, `Grants ${tag(cp, 'name')}; only ${BYPASS_GRANTER} may.`);
      }
    }
  }
}

const scanned = files.filter((f) => f.endsWith('.xml')).length;
if (findings.length === 0) {
  console.log(`Governance check passed: ${scanned} metadata files, 0 findings.`);
  process.exit(0);
}

console.error(`Governance check failed: ${findings.length} finding(s) in ${scanned} metadata files.\n`);
for (const f of findings) console.error(`  [${f.rule}] ${f.file}\n      ${f.msg}`);
process.exit(1);
