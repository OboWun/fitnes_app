import { Injectable } from '@nestjs/common';
import type { ILLMProvider } from './llm-provider.interface.js';
import { findKnowledgeResponse } from '../knowledge/fitness-knowledge.js';

@Injectable()
export class MockLLMProvider implements ILLMProvider {
  async generateResponse(input: {
    messages: { role: string; content: string }[];
    userContext?: string;
  }): Promise<{ content: string }> {
    const lastUserMessage = [...input.messages]
      .reverse()
      .find((m) => m.role === 'user');

    const content = findKnowledgeResponse(lastUserMessage?.content ?? '');

    return { content };
  }
}
