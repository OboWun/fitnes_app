export interface User {
  id: string;
  deviceId: string;
  name?: string;
  weight?: number;
  height?: number;
  age?: number;
  contraindications?: string[];
  createdAt: string;
}
