#include <vector>
#include <ostream>
#include <string>
#ifndef HOTEL_H
#define HOTEL_H

enum class Gender { WOMAN = 0, MAN = 1 };

enum class Action { COMEIN, COMEOUT };

struct Guest {
  int id;
  Gender gender;
};

class Logger {
private:
  std::ostream *output;
  std::ofstream *file_output;
public:
  Logger(std::ostream *, std::ofstream *);
  void logMessage(std::string &);
};

const int SINGLE_ROOMS = 10;
const int DOUBLE_ROOMS = 15;

enum class RoomState { FREE, ONE_MAN, ONE_WOMAN, FULL };

struct Room {
  int number;
  RoomState state;
  std::vector<Guest> guests_in;
  Room(int = -1);
};

class HotelAdministrator {
private:
  std::vector<Room> single_rooms;
  std::vector<Room> double_rooms;
  int last_guest_id;
  Logger logger;

  void settleGuest(Guest&, Room&);

public:
  HotelAdministrator(Logger &);
  int getLastGuestId();
  Room guestComming(Guest &);
  std::pair<Guest, Room> guestLeaving(int);
  void log(std::string &);
};

#endif