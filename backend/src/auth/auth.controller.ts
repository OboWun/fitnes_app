import { Controller, Post, Body } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthService } from './auth.service.js';
import { DeviceAuthDto } from './dto/device-auth.dto.js';
import { AuthResponseDto } from './dto/auth-response.dto.js';

@ApiTags('Auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Post('device')
  @ApiOperation({ summary: 'Login or register via deviceId' })
  @ApiOkResponse({
    type: AuthResponseDto,
    description: 'JWT token and user info',
  })
  async authenticate(@Body() dto: DeviceAuthDto): Promise<AuthResponseDto> {
    const result = await this.authService.authenticate(dto.deviceId);
    return {
      accessToken: result.accessToken,
      user: {
        id: result.user.id,
        deviceId: result.user.deviceId,
        name: result.user.name,
        gender: result.user.gender,
        weight: result.user.weight,
        height: result.user.height,
        age: result.user.age,
        contraindications: result.user.contraindications ?? [],
        createdAt: result.user.createdAt,
      },
    };
  }
}
