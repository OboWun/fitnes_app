export interface PaginationParams {
  offset: number;
  limit: number;
}

export interface PaginatedResult<T> {
  data: T[];
  total: number;
  offset: number;
  limit: number;
}

export interface UseCase<TRequest, TResponse> {
  execute(request: TRequest): Promise<TResponse>;
}

export interface Repository<T, TId = string> {
  findAll(pagination: PaginationParams): Promise<PaginatedResult<T>>;
  findById(id: TId): Promise<T | null>;
  findBySlug(slug: string): Promise<T | null>;
}
