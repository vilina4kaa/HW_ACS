#include "hotel.h"
#include <ostream>
#include <fstream>

// Конструктор логгера. Вывод логов в файл и/или в консоль.
Logger::Logger(std::ostream *output, std::ofstream *file_output = nullptr) 
    : output(output), file_output(file_output) {}

// Логгирование сообщения в консоль и файл (если файл задан).
void Logger::logMessage(std::string &message) {
  *output << message;
  if (file_output) {
    *file_output << message;
  }
}

// Конструктор номера. Изначально номер свободен, список гостей пустой.
Room::Room(int number) : number(number), state(RoomState::FREE) {
  guests_in = std::vector<Guest>();
}

// Конструктор администратора гостиницы. Инициализирует комнаты и задаёт логгер.
HotelAdministrator::HotelAdministrator(Logger &logger) 
    : last_guest_id(0), logger(logger) {
  single_rooms = std::vector<Room>(SINGLE_ROOMS);
  double_rooms = std::vector<Room>(DOUBLE_ROOMS);
  for (int i = 1; i <= SINGLE_ROOMS + DOUBLE_ROOMS; ++i) {
    if (i <= SINGLE_ROOMS) {
      single_rooms[i - 1] = Room(i); // Инициализация одноместных комнат
    } else {
      double_rooms[i - SINGLE_ROOMS - 1] = Room(i); // Инициализация двухместных комнат
    }
  }
}

// Получение ID последнего гостя. 
int HotelAdministrator::getLastGuestId() { 
  return last_guest_id; 
}

// Поселение гостя в номер. Обновляет состояние комнаты и список гостей.
void HotelAdministrator::settleGuest(Guest &guest, Room &room) {
  room.guests_in.push_back(guest);
  ++last_guest_id;
}

// Заселение гостя. Проверяет наличие свободных комнат и заселяет в первую подходящую.
Room HotelAdministrator::guestComming(Guest &guest) {
  // Проверка одноместных номеров
  for (int i = 0; i != SINGLE_ROOMS; ++i) {
    if (single_rooms[i].state == RoomState::FREE) {
      single_rooms[i].state = RoomState::FULL;
      settleGuest(guest, single_rooms[i]);
      return single_rooms[i];
    }
  }
  
  // Проверка двухместных номеров
  for (int i = 0; i != DOUBLE_ROOMS; ++i) {
    if (double_rooms[i].state == RoomState::FREE) {
      double_rooms[i].state = guest.gender == Gender::WOMAN 
                              ? RoomState::ONE_WOMAN 
                              : RoomState::ONE_MAN;
      settleGuest(guest, double_rooms[i]);
      return double_rooms[i];
    }
    if (double_rooms[i].state == RoomState::ONE_MAN && guest.gender == Gender::MAN) {
      double_rooms[i].state = RoomState::FULL;
      settleGuest(guest, double_rooms[i]);
      return double_rooms[i];
    }
    if (double_rooms[i].state == RoomState::ONE_WOMAN && guest.gender == Gender::WOMAN) {
      double_rooms[i].state = RoomState::FULL;
      settleGuest(guest, double_rooms[i]);
      return double_rooms[i];
    }
  }
  // Если подходящий номер не найден
  return Room();
}

// Выселение гостя. Обновляет состояние номера и удаляет гостя из списка.
std::pair<Guest, Room> HotelAdministrator::guestLeaving(int guest_id) {
  Guest leaving_guest;

  // Проверка одноместных номеров
  for (int i = 0; i != SINGLE_ROOMS; ++i) {
    for (int j = 0; j != single_rooms[i].guests_in.size(); ++j) {
      if (single_rooms[i].guests_in[j].id == guest_id) {
        leaving_guest = single_rooms[i].guests_in[j];
        single_rooms[i].guests_in.erase(single_rooms[i].guests_in.begin() + j);
        if (single_rooms[i].guests_in.empty()) {
          single_rooms[i].state = RoomState::FREE; // Номер становится свободным
        }
        return std::make_pair(leaving_guest, single_rooms[i]);
      }
    }
  }

  // Проверка двухместных номеров
  for (int i = 0; i != DOUBLE_ROOMS; ++i) {
    for (int j = 0; j != double_rooms[i].guests_in.size(); ++j) {
      if (double_rooms[i].guests_in[j].id == guest_id) {
        leaving_guest = double_rooms[i].guests_in[j];
        double_rooms[i].guests_in.erase(double_rooms[i].guests_in.begin() + j);
        if (double_rooms[i].guests_in.empty()) {
          double_rooms[i].state = RoomState::FREE; // Номер становится свободным
        } else if (double_rooms[i].guests_in.size() == 1) {
          double_rooms[i].state = double_rooms[i].guests_in[0].gender == Gender::WOMAN 
                                  ? RoomState::ONE_WOMAN 
                                  : RoomState::ONE_MAN;
        }
        return std::make_pair(leaving_guest, double_rooms[i]);
      }
    }
  }
  // Если гость не найден
  return {};
}

// Логгирование сообщения через администратора.
void HotelAdministrator::log(std::string &message) {
  logger.logMessage(message);
}
