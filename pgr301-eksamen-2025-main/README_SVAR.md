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


  