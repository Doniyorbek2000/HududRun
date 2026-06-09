CREATE TABLE IF NOT EXISTS "Squad" (
  "id" TEXT NOT NULL,
  "name" TEXT NOT NULL,
  "tag" TEXT NOT NULL DEFAULT '',
  "color" TEXT NOT NULL DEFAULT '#ADC6FF',
  "isPublic" BOOLEAN NOT NULL DEFAULT true,
  "captainId" TEXT NOT NULL,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "Squad_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "Squad_name_key" ON "Squad"("name");
CREATE UNIQUE INDEX IF NOT EXISTS "Squad_tag_key" ON "Squad"("tag");

CREATE TABLE IF NOT EXISTS "SquadMember" (
  "id" TEXT NOT NULL,
  "squadId" TEXT NOT NULL,
  "userId" TEXT NOT NULL,
  "role" TEXT NOT NULL DEFAULT 'member',
  "joinedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT "SquadMember_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX IF NOT EXISTS "SquadMember_squadId_userId_key" ON "SquadMember"("squadId", "userId");

ALTER TABLE "Squad" ADD CONSTRAINT "Squad_captainId_fkey"
  FOREIGN KEY ("captainId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "SquadMember" ADD CONSTRAINT "SquadMember_squadId_fkey"
  FOREIGN KEY ("squadId") REFERENCES "Squad"("id") ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE "SquadMember" ADD CONSTRAINT "SquadMember_userId_fkey"
  FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
