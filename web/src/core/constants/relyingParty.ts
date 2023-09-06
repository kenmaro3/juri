export const relyingParty = {
  name: process.env.NODE_ENV === 'development' ? 'RAYRIFFY' : 'じゅり',
  id:
    process.env.NODE_ENV === 'development'
      //? 'localhost'
      ? '1417-211-2-3-199.ngrok-free.app'
      : 'juri.rayriffy.com',
}
