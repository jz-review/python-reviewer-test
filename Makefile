GL_SAST_REPORT ?= gl-sast-report.json
SEMGREP_RULES  := \
		  p/eslint-plugin-security \
		  p/gitlab-bandit \
		  p/gitlab-eslint \
		  p/javascript \
		  p/nodejs \
		  p/owasp-top-ten \
		  p/python \
		  p/r2c \
		  p/r2c-ci \
		  p/r2c-security-audit

sast.files:
	jq -r '.vulnerabilities[].location.file' $(GL_SAST_REPORT) \
		| sort -u

sast.report: sast.scan
	jq -r '.vulnerabilities[] | .identifiers[0].value, .identifiers[0].url, .location.file, .location.start_line, .severity, .message' $(GL_SAST_REPORT)

sast.rules:
	jq -r '.vulnerabilities[].identifiers[0].value' $(GL_SAST_REPORT) \
		| sort -u

sast.scan:
	docker run -it --rm \
		--volume $(CURDIR):/src \
		--workdir /src \
		--env SEMGREP_SEND_METRICS=off \
		--env SEMGREP_RULES='$(SEMGREP_RULES)' \
		returntocorp/semgrep:latest \
		semgrep --metrics=off --gitlab-sast --output $(GL_SAST_REPORT)

sast.summary:
	@printf "Vulns found: "
	@jq -r '.vulnerabilities | length' $(GL_SAST_REPORT)
	@printf "Rules triggered: "
	@jq -r '.vulnerabilities[].identifiers[0].value' $(GL_SAST_REPORT) \
		| sort -u
	@printf "Affected files: "
	@jq -r '.vulnerabilities[].location.file' $(GL_SAST_REPORT) \
		| sort -u \
		| wc -l
	@printf "Severity: \n"
	@printf "  Critical: "
	@jq -r '.vulnerabilities[] | select(.severity | test("Critical"))' $(GL_SAST_REPORT) \
		| sort -u \
		| wc -l
	@printf "  High: "
	@jq -r '.vulnerabilities[] | select(.severity | test("High"))' $(GL_SAST_REPORT) \
		| sort -u \
		| wc -l
	@printf "  Medium: "
	@jq -r '.vulnerabilities[] | select(.severity | test("Medium"))' $(GL_SAST_REPORT) \
		| sort -u \
		| wc -l
	@printf "  Low: "
	@jq -r '.vulnerabilities[] | select(.severity | test("Low"))' $(GL_SAST_REPORT) \
		| sort -u \
		| wc -l
	@printf "  Info: "
	@jq -r '.vulnerabilities[] | select(.severity | test("Info"))' $(GL_SAST_REPORT) \
		| sort -u \
		| wc -l

sast.filter:
	@printf "See examples in Makefile and adjust locally\n"
	@printf "jq -r '.vulnerabilities[] | select(.location.file | test(\"server/templates/webOverlay.html\")) | .identifiers[0].value, .identifiers[0].url, .location.file, .location.start_line, .severity, .message'\n" "$(GL_SAST_REPORT)"
	@printf "jq -r '.vulnerabilities[] | select(.identifiers[0].value | test(\"typescript.react.security.audit.react-unsanitized-property.react-unsanitized-property\")) | .identifiers[0].value, .identifiers[0].url, .location.file, .location.start_line, .severity, .message'\n" "$(GL_SAST_REPORT)"

clean:
	rm -f $(GL_SAST_REPORT)
