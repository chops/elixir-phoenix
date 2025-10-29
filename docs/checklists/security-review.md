
Security Review Checklist

Overview

Use before merging security-affecting PRs and before each release.

Authentication & Authorization
	•	All context functions enforce actor + scope checks; tests prove unauthorized calls fail.  
	•	Least-privilege roles documented and enforced in contexts, not only at controllers.  
	•	Rate limits exist per actor and per IP; alert when limits are exceeded.  

Data Protection
	•	PII handling rules documented; storage and processing paths identified.  
	•	Encryption in transit enabled for all external edges (TLS); at-rest controls documented for DB and backups. (Derived from CTO security docs references.)  
	•	Access to PII logged with subject, actor, scope, and correlation ID.  

Dependencies
	•	CI gates run Sobelow and mix_audit on every PR; pipeline fails on findings above triage threshold.  
	•	SBOM is generated per release artifact and archived.  
	•	Regular dependency updates policy exists and is tracked.  

Code Security
	•	Sobelow scan passes locally and in CI with documented ignores only.  
	•	No dynamic SQL without parameters; queries use Ecto bindings or fragments with placeholders. (Backed by Phoenix security checklist ref.)  
	•	External calls mocked via behaviours and Mox in tests to prevent accidental network I/O.  

Audit & Compliance
	•	Append-only audit log implemented with verifier; tamper checks run in CI.  
	•	Structured logs emit correlation IDs and security-relevant metadata; logs retained per policy.  
	•	SOC2/ISO mappings documented for authZ, secrets, logging, and change management.  

Deployment
	•	Secrets loaded only at runtime; none compiled into releases.  
	•	No compile-time env leakage; release uses runtime config for all secrets and endpoints.  
	•	Environments separated (dev/test/stage/prod) with distinct creds and networks; blue-green or rolling strategy defined.  

Common Mistakes to Avoid
	•	Admin endpoints without caps or scope checks.  
	•	Secrets at compile time or in repo.  
	•	Shipping without SBOM or failing to gate on scanner findings.  

Further Reading
	•	Phase 11 security milestone: authZ scopes, secrets, scanners, SBOM, audit log.  
	•	Engineering “Security” checklist items.  
	•	CTO track security references: EEF BEAM Web App Security Best Practices, Phoenix security checklist, Sobelow triage.  

