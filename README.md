# Instant AI Summary

<a href="https://githubsfdeploy.herokuapp.com?owner=baslu93&repo=instant-ai-summary&ref=main">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

A Salesforce LWC that automatically generates an AI-powered record summary when visible, with no user interaction required.

![Instant AI Summary](docs/screenshot_loaded.png)

Standard Salesforce AI Summary generates context when a user clicks a button. This component changes that interaction by running automatically as soon as it becomes visible.

While the Prompt Template runs in the background, the card takes up very little space, showing only a pulsing "AI Summary" title with a sparkle icon. Once the response is ready, the full summary renders directly inside the card, giving users immediate context the moment they open a record.

> [!WARNING]  
> This component consumes tokens when it becomes visible. Consider using it for orgs on an unmetered token tier.

## Setup

### 1. Add the component to a record page

Open App Builder on any Record Page, drag **Instant AI Summary** onto the layout and select the Prompt Template of type **Record Summary** you want to use. Save and activate the page.

### 2. Open a record

Navigate to any record of that object type and the summary will appear automatically on load.

## Components

| Component | Type | Description |
|---|---|---|
| `instantAiSummary` | LWC | Renders the AI-generated summary card on a record page. |
| `AiSummaryGenerateFromPrompt` | Apex | Calls the Einstein LLM API to run the prompt template against the current record. |
| `AiSummaryPromptsFilterByObject` | Apex | Dynamic picklist that filters available prompt templates by the page's object type, used in App Builder configuration. |
| `EinsteinLLMService` | Apex | Interface for the Einstein LLM ConnectApi calls, enabling dependency injection in tests. |
| `EinsteinLLMServiceImpl` | Apex | Production implementation of `EinsteinLLMService` that delegates to `ConnectApi.EinsteinLLM`. |


## Test

Run the setup script to create a scratch org, install the package, deploy test metadata, and seed a sample PersonAccount:

```bash
cd test
./scripts/setup.sh
```

## Requirements

- Salesforce org with Generative AI enabled
