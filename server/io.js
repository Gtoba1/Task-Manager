// server/io.js
// Singleton that holds the Socket.io server instance so controllers can
// emit events directly to specific users without importing server/index.js.

let _io = null;

module.exports = {
  setIO: (io) => { _io = io; },

  // Emit an event to ALL active sockets for a given userId.
  // Uses Socket.io rooms — each user joins room "user:<id>" on connect.
  emitToUser: (userId, event, data) => {
    if (_io) _io.to(`user:${userId}`).emit(event, data);
  },
};
