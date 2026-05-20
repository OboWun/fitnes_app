import { Injectable, Logger } from '@nestjs/common';
import OpenAI from 'openai';
import type { ILLMProvider } from './llm-provider.interface.js';
import { SYSTEM_PROMPT } from './system-prompt.js';
import { findKnowledgeResponse } from '../knowledge/fitness-knowledge.js';

@Injectable()
export class RouterAILLMProvider implements ILLMProvider {
  private readonly logger = new Logger(RouterAILLMProvider.name);
  private readonly client: OpenAI | null = null;
  private readonly model: string;
  private readonly enabled: boolean;

  constructor() {
    const apiKey = process.env.AI_TRAINER;
    const baseURL = process.env.ROUTERAI_BASE_URL ?? 'https://routerai.ru/api/v1';
    this.model = process.env.ROUTERAI_MODEL ?? 'openai/gpt-4o-mini';
    this.enabled = !!apiKey;

    if (this.enabled) {
      this.client = new OpenAI({ apiKey, baseURL });
      this.logger.log(`RouterAI LLM initialized (model: ${this.model})`);
    } else {
      this.logger.warn('AI_TRAINER key not set — using MockLLM fallback');
    }
  }

  async generateResponse(input: {
    messages: { role: string; content: string }[];
    userContext?: string;
  }): Promise<{ content: string }> {
    if (!this.enabled || !this.client) {
      return this.mockFallback(input);
    }

    try {
      const systemMessages: { role: 'system' | 'user' | 'assistant'; content: string }[] = [
        { role: 'system', content: SYSTEM_PROMPT },
      ];

      if (input.userContext) {
        systemMessages.push({ role: 'system', content: input.userContext });
      }

      const chatMessages = input.messages
        .filter((m) => m.role === 'user' || m.role === 'assistant')
        .map((m) => ({
          role: m.role as 'user' | 'assistant',
          content: m.content,
        }));

      const response = await this.client.chat.completions.create({
        model: this.model,
        messages: [...systemMessages, ...chatMessages],
        temperature: 0.7,
        max_tokens: 1000,
      });

      const content = response.choices[0]?.message?.content?.trim();
      if (!content) {
        this.logger.warn('Empty response from RouterAI, using fallback');
        return this.mockFallback(input);
      }

      return { content };
    } catch (error) {
      const err = error as Error;
      this.logger.error(`RouterAI API error: ${err.message}`);
      return this.mockFallback(input);
    }
  }

  private mockFallback(input: {
    messages: { role: string; content: string }[];
  }): { content: string } {
    const lastUserMessage = [...input.messages]
      .reverse()
      .find((m) => m.role === 'user');
    return { content: findKnowledgeResponse(lastUserMessage?.content ?? '') };
  }
}
