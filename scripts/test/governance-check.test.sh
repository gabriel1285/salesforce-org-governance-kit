#!/usr/bin/env bash
# Self-test for scripts/governance-check.js.
# 1. The repo itself must pass.
# 2. A project full of deliberate violations must fail, with every rule reported.
set -euo pipefail

REPO="$(cd "$(dirname "$0")/../.." && pwd)"
CHECK="$REPO/scripts/governance-check.js"

echo "1) Repo passes"
(cd "$REPO" && node "$CHECK")

echo "2) Bad fixture fails with every rule"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
D="$TMP/force-app/main/default"
mkdir -p "$D/objects/Case/validationRules" "$D/objects/Case/fields" "$D/flows" "$D/permissionsets" "$D/profiles"

echo '{"packageDirectories":[{"path":"force-app","default":true}],"sourceApiVersion":"64.0"}' > "$TMP/sfdx-project.json"

cat > "$D/objects/Case/validationRules/No_Bypass.validationRule-meta.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>No_Bypass</fullName>
    <active>true</active>
    <errorConditionFormula>ISBLANK(Subject)</errorConditionFormula>
    <errorMessage>Subject is required.</errorMessage>
</ValidationRule>
XML

# Passes every rule except the description limit (256 characters, the platform accepts 255).
cat > "$D/objects/Case/validationRules/Long_Description.validationRule-meta.xml" <<XML
<?xml version="1.0" encoding="UTF-8"?>
<ValidationRule xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>Long_Description</fullName>
    <active>true</active>
    <description>$(printf 'x%.0s' $(seq 1 256))</description>
    <errorConditionFormula>AND(NOT(\$Permission.Bypass_Validation_Rules), ISBLANK(Subject))</errorConditionFormula>
    <errorMessage>Subject is required.</errorMessage>
</ValidationRule>
XML

cat > "$D/objects/Case/fields/No_Description__c.field-meta.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<CustomField xmlns="http://soap.sforce.com/2006/04/metadata">
    <fullName>No_Description__c</fullName>
    <label>No Description</label>
    <type>Checkbox</type>
    <defaultValue>false</defaultValue>
</CustomField>
XML

cat > "$D/flows/Bad_Flow.flow-meta.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<Flow xmlns="http://soap.sforce.com/2006/04/metadata">
    <apiVersion>64.0</apiVersion>
    <label>Bad Flow</label>
    <processType>AutoLaunchedFlow</processType>
    <recordUpdates>
        <name>Update_Without_Fault</name>
        <label>Update Without Fault</label>
        <inputAssignments>
            <field>OwnerId</field>
            <value><stringValue>00G5g000001AbCdEAF</stringValue></value>
        </inputAssignments>
        <inputReference>$Record</inputReference>
    </recordUpdates>
    <start>
        <object>Case</object>
        <recordTriggerType>Update</recordTriggerType>
        <triggerType>RecordAfterSave</triggerType>
    </start>
    <status>Active</status>
</Flow>
XML

cat > "$D/permissionsets/Too_Powerful.permissionset-meta.xml" <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<PermissionSet xmlns="http://soap.sforce.com/2006/04/metadata">
    <customPermissions>
        <enabled>true</enabled>
        <name>Bypass_Automation</name>
    </customPermissions>
    <label>Too Powerful</label>
    <objectPermissions>
        <allowCreate>true</allowCreate>
        <allowDelete>true</allowDelete>
        <allowEdit>true</allowEdit>
        <allowRead>true</allowRead>
        <modifyAllRecords>true</modifyAllRecords>
        <object>Case</object>
        <viewAllRecords>true</viewAllRecords>
    </objectPermissions>
    <userPermissions>
        <enabled>true</enabled>
        <name>ModifyAllData</name>
    </userPermissions>
</PermissionSet>
XML

echo '<?xml version="1.0" encoding="UTF-8"?><Profile xmlns="http://soap.sforce.com/2006/04/metadata"/>' > "$D/profiles/Custom.profile-meta.xml"

set +e
OUTPUT="$(cd "$TMP" && node "$CHECK" 2>&1)"
STATUS=$?
set -e

echo "$OUTPUT"
[[ $STATUS -ne 0 ]] || { echo "FAIL: bad fixture passed"; exit 1; }

for rule in VR-BYPASS FLOW-BYPASS FLOW-FAULT FLOW-HARDCODE PERM-POWER PERM-BYPASS NO-PROFILES DESCRIPTION; do
  grep -q "\[$rule\]" <<<"$OUTPUT" || { echo "FAIL: rule $rule not reported"; exit 1; }
  echo "  ok  $rule"
done

grep -q "longer than the 255" <<<"$OUTPUT" || { echo "FAIL: over-long description not reported"; exit 1; }
if grep -A1 -E "^\s*\[(VR-BYPASS|FLOW|PERM|NO-PROFILES)" <<<"$OUTPUT" | grep -q "Long_Description"; then
  echo "FAIL: Long_Description should only break the description limit"; exit 1
fi
echo "  ok  DESCRIPTION length"

echo "Self-test passed."
