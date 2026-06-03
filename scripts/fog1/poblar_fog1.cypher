// DESDE EL CONTENEDOR CLIENTE (neo4j-dev-iot) Y A TRAVÉS DEL PROXY
// 1. Entrar en el contenedor: "docker exec -it neo4j-dev-iot bash"
// 2. Mandar el archivo al proxy: "cypher-shell -a neo4j://ha-proxy-1:7687 -u neo4j -p password -d fog1 -f ./scripts/poblar_fog1.cypher"

// Limpieza la base de datos por completo
MATCH (n) DETACH DELETE n;

// Crear constraints
CREATE CONSTRAINT patient_id IF NOT EXISTS
FOR (a:Patient) REQUIRE a.patient_id IS NODE KEY;

CREATE CONSTRAINT encounter_id IF NOT EXISTS
FOR (b:Encounter) REQUIRE b.encounter_id IS NODE KEY;

CREATE CONSTRAINT provider_id IF NOT EXISTS
FOR (c:Provider) REQUIRE c.provider_id IS NODE KEY;

CREATE CONSTRAINT careplan_id IF NOT EXISTS
FOR (d:Careplan) REQUIRE d.careplan_id IS NODE KEY;

CREATE CONSTRAINT organization_id IF NOT EXISTS
FOR (e:Organization) REQUIRE e.organization_id IS NODE KEY;

CREATE CONSTRAINT UDI IF NOT EXISTS
FOR (g:Device) REQUIRE g.UDI IS NODE KEY;

// Nodos Allergy, Condition, Immunization, Medication, Observation,
// Procedure no reciben constraint en este script.

// Crear nodos patients - No se eliminan propiedades
LOAD CSV WITH HEADERS FROM 'file:///patients.csv' AS row
//WITH row LIMIT 59
WITH row LIMIT 39 
MERGE (a:Patient { 
    patient_id: row.Id,
    birthdate: coalesce(CASE WHEN row.BIRTHDATE IS NULL OR row.BIRTHDATE = '' THEN null ELSE date(row.BIRTHDATE) END, ''),
    deathdate: coalesce(CASE WHEN row.DEATHDATE IS NULL OR row.DEATHDATE = '' THEN null ELSE date(row.DEATHDATE) END, ''),
    ssn: coalesce(CASE WHEN row.SSN IS NULL OR row.SSN = '' THEN null ELSE row.SSN END, ''),
    drivers: coalesce(CASE WHEN row.DRIVERS IS NULL OR row.DRIVERS = '' THEN null ELSE row.DRIVERS END, ''),
    passport: coalesce(CASE WHEN row.PASSPORT IS NULL OR row.PASSPORT = '' THEN null ELSE row.PASSPORT END, ''),
    prefix: coalesce(CASE WHEN row.PREFIX IS NULL OR row.PREFIX = '' THEN null ELSE row.PREFIX END, ''),
    first: coalesce(CASE WHEN row.FIRST IS NULL OR row.FIRST = '' THEN null ELSE row.FIRST END, ''),
    middle: coalesce(CASE WHEN row.MIDDLE IS NULL OR row.MIDDLE = '' THEN null ELSE row.MIDDLE END, ''),
    last: coalesce(CASE WHEN row.LAST IS NULL OR row.LAST = '' THEN null ELSE row.LAST END, ''),
    suffix: coalesce(CASE WHEN row.SUFFIX IS NULL OR row.SUFFIX = '' THEN null ELSE row.SUFFIX END, ''),
    maiden: coalesce(CASE WHEN row.MAIDEN IS NULL OR row.MAIDEN = '' THEN null ELSE row.MAIDEN END, ''),
    marital: coalesce(CASE WHEN row.MARITAL IS NULL OR row.MARITAL = '' THEN null ELSE row.MARITAL END, ''),
    race: coalesce(CASE WHEN row.RACE IS NULL OR row.RACE = '' THEN null ELSE row.RACE END, ''),
    ethnicity: coalesce(CASE WHEN row.ETHNICITY IS NULL OR row.ETHNICITY = '' THEN null ELSE row.ETHNICITY END, ''),
    gender: coalesce(CASE WHEN row.GENDER IS NULL OR row.GENDER = '' THEN null ELSE row.GENDER END, ''),
    birthplace: coalesce(CASE WHEN row.BIRTHPLACE IS NULL OR row.BIRTHPLACE = '' THEN null ELSE row.BIRTHPLACE END, ''),
    address: coalesce(CASE WHEN row.ADDRESS IS NULL OR row.ADDRESS = '' THEN null ELSE row.ADDRESS END, ''),
    city: coalesce(CASE WHEN row.CITY IS NULL OR row.CITY = '' THEN null ELSE row.CITY END, ''),
    state: coalesce(CASE WHEN row.STATE IS NULL OR row.STATE = '' THEN null ELSE row.STATE END, ''),
    county: coalesce(CASE WHEN row.COUNTY IS NULL OR row.COUNTY = '' THEN null ELSE row.COUNTY END, ''),
    fips: coalesce(CASE WHEN row.FIPS IS NULL OR row.FIPS = '' THEN null ELSE toInteger(row.FIPS) END, ''),
    location: coalesce(CASE WHEN row.LON IS NULL OR row.LON = '' OR row.LAT IS NULL OR row.LAT = '' THEN null ELSE point({ longitude: toFloat(row.LON), latitude: toFloat(row.LAT) }) END, ''),
    zip: coalesce(CASE WHEN row.ZIP IS NULL OR row.ZIP = '' THEN null ELSE toInteger(row.ZIP) END, ''),
    healthcare_expenses: coalesce(CASE WHEN row.HEALTHCARE_EXPENSES IS NULL OR row.HEALTHCARE_EXPENSES = '' THEN null ELSE toFloat(row.HEALTHCARE_EXPENSES) END, ''),
    healthcare_coverage: coalesce(CASE WHEN row.HEALTHCARE_COVERAGE IS NULL OR row.HEALTHCARE_COVERAGE = '' THEN null ELSE toFloat(row.HEALTHCARE_COVERAGE) END, ''),
    income: coalesce(CASE WHEN row.INCOME IS NULL OR row.INCOME = '' THEN null ELSE toInteger(row.INCOME) END, '')
})
RETURN count(*) AS patients_loaded;

// Crear nodos encounters - Se eliminan propiedades: {patient, organization, provider}
LOAD CSV WITH HEADERS FROM 'file:///encounters.csv' AS row
//WITH row LIMIT 352
WITH row LIMIT 546 
MERGE (b:Encounter { 
    encounter_id: row.Id,
    start: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.START, " ", "T")) END, ''),
    stop: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.STOP, " ", "T")) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    organization: coalesce(CASE WHEN row.ORGANIZATION IS NULL OR row.ORGANIZATION = '' THEN null ELSE row.ORGANIZATION END, ''),
    provider: coalesce(CASE WHEN row.PROVIDER IS NULL OR row.PROVIDER = '' THEN null ELSE row.PROVIDER END, ''),
    encounter_class: coalesce(CASE WHEN row.ENCOUNTERCLASS IS NULL OR row.ENCOUNTERCLASS = '' THEN null ELSE row.ENCOUNTERCLASS END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, ''),
    base_encounter_cost: coalesce(CASE WHEN row.BASE_ENCOUNTER_COST IS NULL OR row.BASE_ENCOUNTER_COST = '' THEN null ELSE toFloat(row.BASE_ENCOUNTER_COST) END, ''),
    total_claim_cost: coalesce(CASE WHEN row.TOTAL_CLAIM_COST IS NULL OR row.TOTAL_CLAIM_COST = '' THEN null ELSE toFloat(row.TOTAL_CLAIM_COST) END, ''),
    reason_code: coalesce(CASE WHEN row.REASONCODE IS NULL OR row.REASONCODE = '' THEN null ELSE toInteger(row.REASONCODE) END, ''),
    reason_description: coalesce(CASE WHEN row.REASONDESCRIPTION IS NULL OR row.REASONDESCRIPTION = '' THEN null ELSE row.REASONDESCRIPTION END, '')
})
RETURN count(*) AS encounters_loaded;

// Crear nodos providers - Se eliminan propiedades: {organization}
LOAD CSV WITH HEADERS FROM 'file:///providers.csv' AS row
MERGE (c:Provider {
    provider_id: row.Id,
    organization: coalesce(CASE WHEN row.ORGANIZATION IS NULL OR row.ORGANIZATION = '' THEN null ELSE row.ORGANIZATION END, ''),
    name: coalesce(CASE WHEN row.NAME IS NULL OR row.NAME = '' THEN null ELSE row.NAME END, ''),
    gender: coalesce(CASE WHEN row.GENDER IS NULL OR row.GENDER = '' THEN null ELSE row.GENDER END, ''),
    speciality: coalesce(CASE WHEN row.SPECIALITY IS NULL OR row.SPECIALITY = '' THEN null ELSE row.SPECIALITY END, ''),
    address: coalesce(CASE WHEN row.ADDRESS IS NULL OR row.ADDRESS = '' THEN null ELSE row.ADDRESS END, ''),
    city: coalesce(CASE WHEN row.CITY IS NULL OR row.CITY = '' THEN null ELSE row.CITY END, ''),
    state: coalesce(CASE WHEN row.STATE IS NULL OR row.STATE = '' THEN null ELSE row.STATE END, ''),
    zip: coalesce(CASE WHEN row.ZIP IS NULL OR row.ZIP = '' THEN null ELSE toInteger(row.ZIP) END, ''),
    num_encounters: coalesce(CASE WHEN row.ENCOUNTERS IS NULL OR row.ENCOUNTERS = '' THEN null ELSE toInteger(row.ENCOUNTERS) END, ''),
    num_procedures: coalesce(CASE WHEN row.PROCEDURES IS NULL OR row.PROCEDURES = '' THEN null ELSE toInteger(row.PROCEDURES) END, ''),
    location: coalesce(CASE WHEN row.LON IS NULL OR row.LON = '' OR row.LAT IS NULL OR row.LAT = '' THEN null ELSE point({ longitude: toFloat(row.LON), latitude: toFloat(row.LAT) }) END, '')
})
RETURN count(*) AS providers_loaded;

// Crear nodos careplans - Se eliminan propiedades: {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///careplans.csv' AS row
//WITH row LIMIT 196
WITH row LIMIT 124 
MERGE (d:Careplan {
    careplan_id: row.Id,
    start: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE date(row.START) END, ''),
    stop: coalesce(CASE WHEN row.STOP IS NULL OR row.STOP = '' THEN null ELSE date(row.STOP) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, ''),
    reason_code: coalesce(CASE WHEN row.REASONCODE IS NULL OR row.REASONCODE = '' THEN null ELSE toInteger(row.REASONCODE) END, ''),
    reason_description: coalesce(CASE WHEN row.REASONDESCRIPTION IS NULL OR row.REASONDESCRIPTION = '' THEN null ELSE row.REASONDESCRIPTION END, '')
})
RETURN count(*) AS careplans_loaded;

// Crear nodos organizations - No se eliminan propiedades
LOAD CSV WITH HEADERS FROM 'file:///organizations.csv' AS row
MERGE (e:Organization {
    organization_id: row.Id,
    name: coalesce(CASE WHEN row.NAME IS NULL OR row.NAME = '' THEN null ELSE row.NAME END, ''),
    address: coalesce(CASE WHEN row.ADDRESS IS NULL OR row.ADDRESS = '' THEN null ELSE row.ADDRESS END, ''),
    city: coalesce(CASE WHEN row.CITY IS NULL OR row.CITY = '' THEN null ELSE row.CITY END, ''),
    state: coalesce(CASE WHEN row.STATE IS NULL OR row.STATE = '' THEN null ELSE row.STATE END, ''),
    zip: coalesce(CASE WHEN row.ZIP IS NULL OR row.ZIP = '' THEN null ELSE toInteger(row.ZIP) END, ''),
    location: coalesce(CASE WHEN row.LON IS NULL OR row.LON = '' OR row.LAT IS NULL OR row.LAT = '' THEN null ELSE point({ longitude: toFloat(row.LON), latitude: toFloat(row.LAT) }) END, ''),
    phone: coalesce(CASE WHEN row.PHONE IS NULL OR row.PHONE = '' THEN null ELSE toInteger(row.PHONE) END, ''),
    revenue: coalesce(CASE WHEN row.REVENUE IS NULL OR row.REVENUE = '' THEN null ELSE toFloat(row.REVENUE) END, ''),
    utilization: coalesce(CASE WHEN row.UTILIZATION IS NULL OR row.UTILIZATION = '' THEN null ELSE toInteger(row.UTILIZATION) END, '')
})
RETURN count(*) AS organizations_loaded;

// Crear nodos devices - Se eliminan propiedades {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///devices.csv' AS row
//WITH row LIMIT 103
WITH row LIMIT 187
MERGE (g:Device { 
    UDI: row.UDI,
    start: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.START, " ", "T")) END, ''),
    stop: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.STOP, " ", "T")) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, '')
})
RETURN count(*) AS devices_loaded;

// Crear nodos allergies - Se eliminan propiedades {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///allergies.csv' AS row
//WITH row LIMIT 69
WITH row LIMIT 54 
MERGE (i:Allergy {
    start: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE date(row.START) END, ''),
    stop: coalesce(CASE WHEN row.STOP IS NULL OR row.STOP = '' THEN null ELSE date(row.STOP) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    system: coalesce(CASE WHEN row.SYSTEM IS NULL OR row.SYSTEM = '' THEN null ELSE row.SYSTEM END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, ''),
    type: coalesce(CASE WHEN row.TYPE IS NULL OR row.TYPE = '' THEN null ELSE row.TYPE END, ''),
    category: coalesce(CASE WHEN row.CATEGORY IS NULL OR row.CATEGORY = '' THEN null ELSE row.CATEGORY END, ''),
    reaction_1: coalesce(CASE WHEN row.REACTION1 IS NULL OR row.REACTION1 = '' THEN null ELSE toInteger(row.REACTION1) END, ''),
    description_1: coalesce(CASE WHEN row.DESCRIPTION1 IS NULL OR row.DESCRIPTION1 = '' THEN null ELSE row.DESCRIPTION1 END, ''),
    severity_1: coalesce(CASE WHEN row.SEVERITY1 IS NULL OR row.SEVERITY1 = '' THEN null ELSE row.SEVERITY1 END, ''),
    reaction_2: coalesce(CASE WHEN row.REACTION2 IS NULL OR row.REACTION2 = '' THEN null ELSE toInteger(row.REACTION2) END, ''),
    description_2: coalesce(CASE WHEN row.DESCRIPTION2 IS NULL OR row.DESCRIPTION2 = '' THEN null ELSE row.DESCRIPTION2 END, ''),
    severity_2: coalesce(CASE WHEN row.SEVERITY2 IS NULL OR row.SEVERITY2 = '' THEN null ELSE row.SEVERITY2 END, '')
})
RETURN count(*) AS allergies_loaded;

// Crear nodos conditions - Se eliminan propiedades {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///conditions.csv' AS row
//WITH row LIMIT 233
WITH row LIMIT 1132
MERGE (l:Condition {
    start: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE date(row.START) END, ''),
    stop: coalesce(CASE WHEN row.STOP IS NULL OR row.STOP = '' THEN null ELSE date(row.STOP) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    system: coalesce(CASE WHEN row.SYSTEM IS NULL OR row.SYSTEM = '' THEN null ELSE row.SYSTEM END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, '')
})
RETURN count(*) AS conditions_loaded;

// Crear nodos immunizations - Se eliminan propiedades {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///immunizations.csv' AS row 
//WITH row LIMIT 236
WITH row LIMIT 530 
MERGE (m:Immunization {
    date: coalesce(CASE WHEN row.DATE IS NULL OR row.DATE = '' THEN null ELSE datetime(replace(row.DATE, " ", "T")) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, ''),
    base_cost: coalesce(CASE WHEN row.BASE_COST IS NULL OR row.BASE_COST = '' THEN null ELSE toFloat(row.BASE_COST) END, '')
})
RETURN count(*) AS immunizations_loaded;

// Crear nodos medications - Se eliminan propiedades {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///medications.csv' AS row
//WITH row LIMIT 214
WITH row LIMIT 507 
MERGE (n:Medication {
    start: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.START, " ", "T")) END, ''),
    stop: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.STOP, " ", "T")) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, ''),
    base_cost: coalesce(CASE WHEN row.BASE_COST IS NULL OR row.BASE_COST = '' THEN null ELSE toFloat(row.BASE_COST) END, ''),
    dispenses: coalesce(CASE WHEN row.DISPENSES IS NULL OR row.DISPENSES = '' THEN null ELSE toInteger(row.DISPENSES) END, ''),
    total_cost: coalesce(CASE WHEN row.TOTALCOST IS NULL OR row.TOTALCOST = '' THEN null ELSE toFloat(row.TOTALCOST) END, ''),
    reason_code: coalesce(CASE WHEN row.REASONCODE IS NULL OR row.REASONCODE = '' THEN null ELSE toInteger(row.REASONCODE) END, ''),
    reason_description: coalesce(CASE WHEN row.REASONDESCRIPTION IS NULL OR row.REASONDESCRIPTION = '' THEN null ELSE row.REASONDESCRIPTION END, '')
})
RETURN count(*) AS medications_loaded;

// Crear nodos observations - Se eliminan propiedades {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///observations.csv' AS row
//WITH row LIMIT 354
WITH row LIMIT 546 
MERGE (o:Observation {
    date: coalesce(CASE WHEN row.DATE IS NULL OR row.DATE = '' THEN null ELSE datetime(replace(row.DATE, " ", "T")) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    category: coalesce(CASE WHEN row.CATEGORY IS NULL OR row.CATEGORY = '' THEN null ELSE row.CATEGORY END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE row.CODE END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, ''),
    value: coalesce(CASE WHEN row.VALUE IS NULL OR row.VALUE = '' THEN null ELSE row.VALUE END, ''),
    units: coalesce(CASE WHEN row.UNITS IS NULL OR row.UNITS = '' THEN null ELSE row.UNITS END, ''),
    type: coalesce(CASE WHEN row.TYPE IS NULL OR row.TYPE = '' THEN null ELSE row.TYPE END, '')
})
RETURN count(*) AS observations_loaded;

// Crear nodos procedures - Se eliminan propiedades {patient, encounter}
LOAD CSV WITH HEADERS FROM 'file:///procedures.csv' AS row
//WITH row LIMIT 232
WITH row LIMIT 546 
MERGE (q:Procedure {
    start: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.START, " ", "T")) END, ''),
    stop: coalesce(CASE WHEN row.START IS NULL OR row.START = '' THEN null ELSE datetime(replace(row.STOP, " ", "T")) END, ''),
    patient: coalesce(CASE WHEN row.PATIENT IS NULL OR row.PATIENT = '' THEN null ELSE row.PATIENT END, ''),
    encounter: coalesce(CASE WHEN row.ENCOUNTER IS NULL OR row.ENCOUNTER = '' THEN null ELSE row.ENCOUNTER END, ''),
    system: coalesce(CASE WHEN row.SYSTEM IS NULL OR row.SYSTEM = '' THEN null ELSE row.SYSTEM END, ''),
    code: coalesce(CASE WHEN row.CODE IS NULL OR row.CODE = '' THEN null ELSE toInteger(row.CODE) END, ''),
    description: coalesce(CASE WHEN row.DESCRIPTION IS NULL OR row.DESCRIPTION = '' THEN null ELSE row.DESCRIPTION END, ''),
    base_cost: coalesce(CASE WHEN row.BASE_COST IS NULL OR row.BASE_COST = '' THEN null ELSE toFloat(row.BASE_COST) END, ''),
    reason_code: coalesce(CASE WHEN row.REASONCODE IS NULL OR row.REASONCODE = '' THEN null ELSE toInteger(row.REASONCODE) END, ''),
    reason_description: coalesce(CASE WHEN row.REASONDESCRIPTION IS NULL OR row.REASONDESCRIPTION = '' THEN null ELSE row.REASONDESCRIPTION END, '')
})
RETURN count(*) AS procedures_loaded;

// ============================================================================
// RELACIONES Y LIMPIEZA DE FKs REDUNDANTES
// Ejecutar después de haber cargado todos los nodos.
// ============================================================================

// -----------------------------
// 1) RELACIONES MAESTRAS
// -----------------------------

// Patient -> Encounter
MATCH (p:Patient), (e:Encounter)
WHERE e.patient <> '' AND p.patient_id = e.patient
MERGE (p)-[:UNDERWENT]->(e);

// Encounter -> Organization
MATCH (e:Encounter), (o:Organization)
WHERE e.organization <> '' AND o.organization_id = e.organization
MERGE (e)-[:AT_ORGANIZATION]->(o);

// Encounter -> Provider
MATCH (e:Encounter), (pr:Provider)
WHERE e.provider <> '' AND pr.provider_id = e.provider
MERGE (e)-[:WITH_PROVIDER]->(pr);

// Provider -> Organization
MATCH (pr:Provider), (o:Organization)
WHERE pr.organization <> '' AND o.organization_id = pr.organization
MERGE (pr)-[:WORKS_AT]->(o);

// -----------------------------
// 2) RELACIONES CLÍNICAS
// -----------------------------

// Patient -> Allergy
MATCH (p:Patient), (a:Allergy)
WHERE a.patient <> '' AND p.patient_id = a.patient
MERGE (p)-[:HAS_ALLERGY]->(a);

// Allergy -> Encounter
MATCH (a:Allergy), (e:Encounter)
WHERE a.encounter <> '' AND e.encounter_id = a.encounter
MERGE (a)-[:DIAGNOSED_IN]->(e);

// Patient -> Careplan
MATCH (p:Patient), (c:Careplan)
WHERE c.patient <> '' AND p.patient_id = c.patient
MERGE (p)-[:HAS_CAREPLAN]->(c);

// Careplan -> Encounter
MATCH (c:Careplan), (e:Encounter)
WHERE c.encounter <> '' AND e.encounter_id = c.encounter
MERGE (c)-[:STARTED_IN]->(e);

// Patient -> Condition
MATCH (p:Patient), (c:Condition)
WHERE c.patient <> '' AND p.patient_id = c.patient
MERGE (p)-[:HAS_CONDITION]->(c);

// Condition -> Encounter
MATCH (c:Condition), (e:Encounter)
WHERE c.encounter <> '' AND e.encounter_id = c.encounter
MERGE (c)-[:RECORDED_IN]->(e);

// Patient -> Device
MATCH (p:Patient), (d:Device)
WHERE d.patient <> '' AND p.patient_id = d.patient
MERGE (p)-[:USES_DEVICE]->(d);

// Device -> Encounter
MATCH (d:Device), (e:Encounter)
WHERE d.encounter <> '' AND e.encounter_id = d.encounter
MERGE (d)-[:REGISTERED_IN]->(e);

// Patient -> Immunization
MATCH (p:Patient), (i:Immunization)
WHERE i.patient <> '' AND p.patient_id = i.patient
MERGE (p)-[:HAS_IMMUNIZATION]->(i);

// Immunization -> Encounter
MATCH (i:Immunization), (e:Encounter)
WHERE i.encounter <> '' AND e.encounter_id = i.encounter
MERGE (i)-[:ADMINISTERED_IN]->(e);

// Patient -> Medication
MATCH (p:Patient), (m:Medication)
WHERE m.patient <> '' AND p.patient_id = m.patient
MERGE (p)-[:HAS_MEDICATION]->(m);

// Medication -> Encounter
MATCH (m:Medication), (e:Encounter)
WHERE m.encounter <> '' AND e.encounter_id = m.encounter
MERGE (m)-[:PRESCRIBED_IN]->(e);

// Patient -> Observation
MATCH (p:Patient), (o:Observation)
WHERE o.patient <> '' AND p.patient_id = o.patient
MERGE (p)-[:HAS_OBSERVATION]->(o);

// Observation -> Encounter (opcional)
MATCH (o:Observation), (e:Encounter)
WHERE o.encounter <> '' AND e.encounter_id = o.encounter
MERGE (o)-[:TAKEN_AT]->(e);

// Patient -> Procedure
MATCH (p:Patient), (prc:Procedure)
WHERE prc.patient <> '' AND p.patient_id = prc.patient
MERGE (p)-[:HAS_PROCEDURE]->(prc);

// Procedure -> Encounter
MATCH (prc:Procedure), (e:Encounter)
WHERE prc.encounter <> '' AND e.encounter_id = prc.encounter
MERGE (prc)-[:PERFORMED_IN]->(e);

// ============================================================================
// LIMPIEZA DE PROPIEDADES FK REDUNDANTES
// ============================================================================

// Encounter
MATCH (n:Encounter)
REMOVE n.patient, n.organization, n.provider;

// Provider
MATCH (n:Provider)
REMOVE n.organization;

// Allergy
MATCH (n:Allergy)
REMOVE n.patient, n.encounter;

// Careplan
MATCH (n:Careplan)
REMOVE n.patient, n.encounter;

// Condition
MATCH (n:Condition)
REMOVE n.patient, n.encounter;

// Device
MATCH (n:Device)
REMOVE n.patient, n.encounter;

// Immunization
MATCH (n:Immunization)
REMOVE n.patient, n.encounter;

// Medication
MATCH (n:Medication)
REMOVE n.patient, n.encounter;

// Observation
MATCH (n:Observation)
REMOVE n.patient, n.encounter;

// Procedure
MATCH (n:Procedure)
REMOVE n.patient, n.encounter;
