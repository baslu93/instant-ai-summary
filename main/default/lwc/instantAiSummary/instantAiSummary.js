import { LightningElement, api } from 'lwc';
import generate from '@salesforce/apex/AiSummaryGenerateFromPrompt.generate';
import TITLE from '@salesforce/label/c.InstantAiSummary_Title';

export default class InstantAiSummary extends LightningElement {
    @api recordId;
    @api promptTemplate;
    richText;
    hasAnswer = false;

    get cardClass() {
        return this.hasAnswer ? 'ai-answer-card ai-answer-card--loaded' : 'ai-answer-card';
    }

    get iconClass() {
        return this.hasAnswer ? 'ai-sparkle-icon' : 'ai-sparkle-icon pulse';
    }

    get titleChars() {
        return [...TITLE].map((char, i) => ({
            index: i,
            char: char === ' ' ? ' ' : char,
            cssClass: this.hasAnswer ? '' : 'pulse',
            style: `animation-delay: ${i * 100}ms`
        }));
    }

    async connectedCallback() {
        if (this.promptTemplate && this.recordId) {
            this.loadSummary();
        }
    }

    async loadSummary() {
        try {
            const result = await generate({
                promptTemplateDeveloperName: this.promptTemplate,
                recordId: this.recordId
            });
            this.richText = result;
            this.hasAnswer = true;
        } catch (error) {
            console.error('Error generating summary:', error);
        }
    }
}
