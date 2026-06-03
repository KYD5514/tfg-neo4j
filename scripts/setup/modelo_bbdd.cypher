MODELO DE LA BASE DE DATOS:

Patient
 ├─ UNDERWENT(1) ───────────────> Encounter
 │                                 ├─ AT_ORGANIZATION(10) ─> Organization
 │                                 ├─ WITH_PROVIDER(11) ───> Provider ───── WORKS_AT(20) ─> Organization
 │                                 
 │
 ├─ HAS_CONDITION(2) ───────────────> Condition ── RECORDED_IN(13)1 ──> Encounter
 ├─ HAS_OBSERVATION(3) ─────────────> Observation ─ TAKEN_AT(14)1 ─> Encounter
 ├─ HAS_PROCEDURE(4) ───────────────> Procedure ── PERFORMED_IN(15)1 ─> Encounter
 ├─ HAS_MEDICATION(5) ──────────────> Medication ─ PRESCRIBED_IN(16)1 ─> Encounter
 │                                
 ├─ HAS_IMMUNIZATION(6) ────────────> Immunization ─ ADMINISTERED_IN(17) ──> Encounter
 ├─ HAS_ALLERGY(7) ─────────────────> Allergy ───── DIAGNOSED_IN(18) ──> Encounter
 ├─ HAS_CAREPLAN(8) ────────────────> CarePlan ──── STARTED_IN(19) ──> Encounter
 ├─ USES_DEVICE(9) ─────────────────> Device ────── REGISTERED_IN(20) ──> Encounter