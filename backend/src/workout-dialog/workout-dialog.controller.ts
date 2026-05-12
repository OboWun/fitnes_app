import {
  Controller,
  Post,
  Get,
  Delete,
  Param,
  Body,
  UseGuards,
  UsePipes,
  ValidationPipe,
  NotFoundException,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiNoContentResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard.js';
import { CurrentUser } from '../auth/decorators/current-user.decorator.js';
import type { User } from '../entities/index.js';
import { WorkoutDialogService } from './workout-dialog.service.js';
import { DialogAnswerDto } from './dto/dialog-answer.dto.js';
import { DialogStepResponseDto } from './dto/dialog-step-response.dto.js';
import { DialogCompleteResponseDto } from './dto/dialog-complete-response.dto.js';

@ApiTags('Workout Dialog')
@ApiBearerAuth()
@Controller('workout-dialog')
@UseGuards(JwtAuthGuard)
export class WorkoutDialogController {
  constructor(private readonly dialogService: WorkoutDialogService) {}

  @Post('start')
  @ApiOperation({ summary: 'Start a new workout parameter dialog' })
  @ApiCreatedResponse({ type: DialogStepResponseDto })
  async start(@CurrentUser() user: User): Promise<DialogStepResponseDto> {
    const result = await this.dialogService.startDialog(user.id);

    return {
      dialogId: result.dialog.id,
      step: result.step,
      question: result.question,
      description: result.description,
      inputType: result.inputType,
      options: result.options,
      canSkip: result.canSkip,
      collectedSoFar: result.dialog.collectedParams,
    };
  }

  @Post(':dialogId/answer')
  @ApiOperation({ summary: 'Submit answer for current dialog step' })
  @ApiCreatedResponse({ type: DialogStepResponseDto })
  @UsePipes(new ValidationPipe({ whitelist: true }))
  async answer(
    @CurrentUser() user: User,
    @Param('dialogId') dialogId: string,
    @Body() dto: DialogAnswerDto,
  ): Promise<DialogStepResponseDto | DialogCompleteResponseDto> {
    const result = await this.dialogService.answerStep(dialogId, dto.answer);

    if (result.completed) {
      const response = new DialogCompleteResponseDto();
      response.dialogId = result.dialog.id;
      response.step = 'complete';
      response.planType = result.planType;
      if (result.planType === 'weekly') {
        response.weeklyParams = result.params;
      } else {
        response.generateParams = result.params;
      }
      return response;
    }

    return {
      dialogId: result.dialog.id,
      step: result.step,
      question: result.question,
      description: result.description,
      inputType: result.inputType,
      options: result.options,
      canSkip: result.canSkip,
      collectedSoFar: result.dialog.collectedParams,
    };
  }

  @Delete(':dialogId')
  @ApiOperation({ summary: 'Delete a dialog' })
  @ApiNoContentResponse({ description: 'Dialog deleted' })
  @HttpCode(HttpStatus.NO_CONTENT)
  async delete(
    @CurrentUser() user: User,
    @Param('dialogId') dialogId: string,
  ): Promise<void> {
    const deleted = await this.dialogService.deleteDialog(dialogId, user.id);
    if (!deleted) {
      throw new NotFoundException('Dialog not found');
    }
  }

  @Get(':dialogId')
  @ApiOperation({ summary: 'Get current state of a dialog' })
  @ApiOkResponse({ type: DialogStepResponseDto })
  async getState(
    @CurrentUser() _user: User,
    @Param('dialogId') dialogId: string,
  ): Promise<DialogStepResponseDto> {
    const result = await this.dialogService.getState(dialogId);
    if (!result) {
      throw new NotFoundException('Dialog not found or already completed');
    }

    return {
      dialogId: result.dialog.id,
      step: result.step,
      question: result.question,
      description: result.description,
      inputType: result.inputType,
      options: result.options,
      canSkip: result.canSkip,
      collectedSoFar: result.dialog.collectedParams,
    };
  }
}
