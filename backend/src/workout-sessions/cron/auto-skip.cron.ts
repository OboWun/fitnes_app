import { Injectable, Logger } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { Inject } from '@nestjs/common';
import {
  WORKOUT_SESSIONS_REPOSITORY,
  type IWorkoutSessionsRepository,
} from '../../common/repositories/index.js';

@Injectable()
export class AutoSkipCron {
  private readonly logger = new Logger(AutoSkipCron.name);

  constructor(
    @Inject(WORKOUT_SESSIONS_REPOSITORY)
    private readonly sessionsRepo: IWorkoutSessionsRepository,
  ) {}

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async handleStalePlannedSessions(): Promise<void> {
    const stale = await this.sessionsRepo.findStalePlanned();
    if (!stale.length) return;

    this.logger.log(`Auto-skipping ${stale.length} stale planned sessions`);

    for (const session of stale) {
      await this.sessionsRepo.skipSession(session.id, true);
      this.logger.log(`Auto-skipped session ${session.id} (day: ${session.dayOfWeek})`);
    }
  }
}
