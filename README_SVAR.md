## Oppgave 1 – AWS Lambda, SAM og GitHub Actions
Jeg har opprettet en egen mappe `infra-s3/` der all Terraform-kode ligger. Terraform-konfigurasjonen oppretter en S3-bucket for analyseresultater med navnet kandidat-70-data.
Jeg har laget en lifecycle-policy som gjelder for filer under prefix midlertidig/, der filer flyttes til Glacier etter 7 dager og slettes etter 30 dager. Filer utenfor dette området påvirkes ikke. Alle verdier som navn, region og tidsgrenser er variabler for å unngå hardkoding.


## Oppgave 2 – AWS Lambda, SAM og GitHub Actions

### Del A – Deploy og test av SAM-applikasjonen

Jeg har tatt utgangspunkt i SAM-applikasjonen i `sam-comprehend/` og koblet den mot S3-bucketen fra oppgave 1.

---
### 1.
I sam-comprehend/ ligger en enkel SAM-applikasjon med:
- template.yaml
- sentiment_function/app.py
Dette gir et lite serverless API som analyserer tekst og lagrer resultatet i S3.

### 2. 
Endringer i `template.yaml`:

- Under `Globals` har jeg satt:
  ```yaml
  Globals:
    Function:
      Timeout: 30
      MemorySize: 256
      Runtime: python3.11
    Api:
      EndpointConfiguration: REGIONAL

Videre peker parameteren S3BucketName på min bucket: kandidat-70-data
Slik kan Lambda skrive resultatene direkte til S3-bucketen.

### 3.
Jeg kjørte applikasjonen med "sam build" og "sam local invoke"
Når Lambda kjører uten tekst-payload returnerer den en feilmelding:
{"error": "Text field is required"}
Dette viser at applikasjonen kjører lokalt med riktif kode og runtime

### 4.
Jeg deployet applikasjonen med "sam deploy --guided" og valgte: 
Stack name: kandidat-70-sam
Region: eu-west-1
S3BucketName: kandidat-70-data
IAM role creation: Yes
Endpoint type: REGIONAL

Dette resulterte i en vellykket deploy.

### 5.
Link til API: https://ohjnhpxou3.execute-api.eu-west-1.amazonaws.com/Prod/analyze/

Jeg testet med Postman ved å sende POST-req:
{
  "text": "Apple launches groundbreaking new AI features while Microsoft faces cloud security concerns."
}
Outputtet viste riktig sentimentanalyse fra Amazon Comprehend.

### Del B – Fiks GitHub Actions Workflow
Jeg har endret workflowen slik at den følger god DevOps praksis:

- På Pull Request kjøres kun:
  - `sam validate`
  - `sam build`
- På push til main kjøres:
  - `sam validate`
  - `sam build`
  - `sam deploy`

Hardkodede verdier er erstattet med kandidatnummer (70) og GitHub Secrets brukes for AWS-nøkler.

Jeg oppdaget at GitHub Actions brukte Python 3.9, mens Lambda var satt til python3.11. Dette førte til feil under sam build. Jeg løste dette ved å oppdatere workflowen til å bruke Python 3.11, som gjorde at byggingen fungerte korrekt.

Workflow-fil:
https://github.com/malinash/EksamenPGR301/blob/main/.github/workflows/sam-deploy.yml

Vellykket deploy (push til main):
https://github.com/malinash/EksamenPGR301/actions/runs/19558456996

PR-validering (uten deploy):
https://github.com/malinash/EksamenPGR301/pull/2

For at workflowen skal kjøre i sensor sitt repo må følgende secrets legges til:

AWS_ACCESS_KEY_ID

AWS_SECRET_ACCESS_KEY

CANDIDATE_ID

## Oppgave 3 – Container og Docker

### Del A
Jeg containeriserte Spring Boot-applikasjonen ved å lage en Dockerfile med multi-stage build (Maven + Java 21 for bygging og Amazon Corretto 21 Alpine for runtime). Containeren ble kjørt med nødvendige AWS-miljøvariabler og eksponerte port 8080.
Ble testet med POST-req til /api/analyze, og returnerte korrekt AI-basert sentimentanalyse fra AWS Bedrock.

### Del B
Workflow fil:
https://github.com/malinash/EksamenPGR301/actions/runs/19561732129

Jeg valgte å bruke to tags for Docker-imaget:

- `latest` – peker alltid på siste vellykkede build fra `main`. Dette gjør det enkelt å bruke imaget i f.eks. test- og demo-miljøer uten å måtte oppdatere tag hver gang.
- `sha-<commit>` (`sha-${GIT_SHA}`) – en unik tag per commit. Denne gjør det mulig å spore nøyaktig hvilken kodeversjon et image er bygget fra, og gjør rollback og debugging enklere hvis noe går galt i et senere deploy.

Kombinasjonen av `latest` + `sha-commit` gir både enkel bruk og god sporbarhet.

For at `.github/workflows/docker-build.yml` skal fungere i en fork, må sensor:
Legge inn secrets:
  - `DOCKER_USERNAME` = Docker Hub-brukernavn
   - `DOCKER_TOKEN` = Docker Hub access token

Workflowen vil da automatisk pushe til:
<DOCKER_USERNAME>/sentiment-docker:latest