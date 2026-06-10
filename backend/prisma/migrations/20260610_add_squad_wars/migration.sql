CREATE TABLE IF NOT EXISTS "SquadWar" (
  "id" TEXT NOT NULL,
  "startDate" TIMESTAMP(3) NOT NULL,
  "endDate" TIMESTAMP(3) NOT NULL,
  "status" TEXT NOT NULL DEFAULT 'active',
  "winnerId" TEXT,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SquadWar_pkey" PRIMARY KEY ("id")
);

CREATE TABLE IF NOT EXISTS "SquadWarParticipant" (
  "id" TEXT NOT NULL,
  "warId" TEXT NOT NULL,
  "squadId" TEXT NOT NULL,
  "score" DOUBLE PRECISION NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SquadWarParticipant_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "SquadWarParticipant_warId_squadId_key" ON "SquadWarParticipant"("warId", "squadId");

ALTER TABLE "SquadWar" ADD CONSTRAINT "SquadWar_winnerId_fkey"
  FOREIGN KEY ("winnerId") REFERENCES "Squad"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "SquadWarParticipant" ADD CONSTRAINT "SquadWarParticipant_warId_fkey"
  FOREIGN KEY ("warId") REFERENCES "SquadWar"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "SquadWarParticipant" ADD CONSTRAINT "SquadWarParticipant_squadId_fkey"
  FOREIGN KEY ("squadId") REFERENCES "Squad"("id") ON DELETE CASCADE ON UPDATE CASCADE;
