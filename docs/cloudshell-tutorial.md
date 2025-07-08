# Circuit Breaking

This sample creates an LLM proxy with 2 target pools: Primary and Secondary. The primary target is pointing to the OpenAI model and the secondary target is pointing to the Gemini model. It will also create a Cloud Task queue to simulate a burst of API calls intended to reach and exceed the Primary target quota. the LLM proxy will automatically retry the overflowing calls to the Secondary target pool.

Let's get started!

---

## Prepare project dependencies

### 1. Select the project with an active Apigee instance

<walkthrough-project-setup></walkthrough-project-setup>

### 2. Ensure you have an active GCP account selected in the Cloud Shell

```sh
gcloud auth login
```

### 3. Ensure you have an active GCP account selected in the Cloud Shell

```sh
gcloud config set project <walkthrough-project-id/>
```
### 4. Enable the Services required to deploy this sample

```sh
gcloud services enable aiplatform.googleapis.com cloudtasks.googleapis.com  --project <walkthrough-project-id/>
```

## Set environment variables

### 1. Edit the following variables in the `env.sh` file

Open the environment variables file <walkthrough-editor-open-file filePath="env.sh">env.sh</walkthrough-editor-open-file> and set the following variables:

* Set the <walkthrough-editor-select-regex filePath="env.sh" regex="APIGEE_PROJECT_ID_TO_SET">APIGEE_PROJECT</walkthrough-editor-select-regex>. The value should be <walkthrough-project-id/>.
* Set the <walkthrough-editor-select-regex filePath="env.sh" regex="APIGEE_HOST_TO_SET">APIGEE_HOST</walkthrough-editor-select-regex> of your Apigee instance. For example, `my-test.nip.io`.
* Set the <walkthrough-editor-select-regex filePath="env.sh" regex="APIGEE_ENV_TO_SET">APIGEE_ENV</walkthrough-editor-select-regex> to the deploy the sample Apigee artifacts. For example, `dev-env`.
* Set the <walkthrough-editor-select-regex filePath="env.sh" regex="APIGEE_REGION_TO_SET">APIGEE_REGION</walkthrough-editor-select-regex> to the region of your Apigee instance. For example, `us-central1`.
* Set the <walkthrough-editor-select-regex filePath="env.sh" regex="OPENAI_API_KEY_TO_SET">OPENAI_API_KEY</walkthrough-editor-select-regex> with the OpenAI API key.
* Set the <walkthrough-editor-select-regex filePath="env.sh" regex="GEMINI_API_KEY_TO_SET">GEMINI_API_KEY</walkthrough-editor-select-regex> with the Gemini API key.

### 2. Set environment variables

```sh
source ./env.sh
```

## Create a Task Queue

This task queue will allow you to send concurrent request to an LLM endpoint.

### 1. Create a Queue

```sh
gcloud tasks queues create ai-queue --location=$APIGEE_REGION
```

## Deploy sample artifacts

### Execute deployment script

```sh
./deploy-llm-circuit-breaking.sh
```

## Congratulations

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

You're all set!

You can now go back to the [notebook](https://github.com/ssvaidyanathan/llm-circuit-breaking-demo/blob/main/llm_circuit_breaking.ipynb) to test the sample.

**Don't forget to clean up after yourself**. Execute the following script to undeploy and delete all sample resources.
```sh
./undeploy-llm-circuit-breaking.sh
```