export interface LLMResponse {
  content: string;
}

export const LLM_PROVIDER = Symbol('LLM_PROVIDER');

export interface ILLMProvider {
  generateResponse(input: {
    messages: { role: string; content: string }[];
    userContext?: string;
  }): Promise<LLMResponse>;
}
