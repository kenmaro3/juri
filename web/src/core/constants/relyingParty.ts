export const relyingParty = {
  name: process.env.NODE_ENV === 'development' ? 'RAYRIFFY' : 'じゅり',
  id:
    process.env.NODE_ENV === 'development'
      //? 'localhost'
      ? '0f50-2001-f70-96a0-3800-19db-e81-64c2-46f6.ngrok-free.app'
      : 'juri.rayriffy.com',
}
