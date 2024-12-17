#include "main.h"
#include <format>
#include <fstream>
#include <unistd.h>
#include <queue>

int main(int argc, char *argv[]) {
  // Дефолтное значение количества клиентов (= 0) устанавливается для того, чтобы потом изменить их, прочитав либор из командной строки, либо из файла, либо из консоли
  int clients = DEFAULT_CLIENTS_AMOUNT;
  setArgs(clients, input, argc, argv);  // Устанавливаем значение через аргументы 
  Logger logger = file_output? Logger(output, file_output) : Logger(output, nullptr);  // Если из консоли не введено имя выходного файла, то дефолтный вывод только в консоль.
  
  // Если не передано имя входного файла, то проверяем, задано ли количество через аргументы
  if (file_input) {
    std::tie(logger, clients) = readArgsFromFile();
  } else if (clients == DEFAULT_CLIENTS_AMOUNT) {  // Если количество гостей не было указано через аргумент (т.е. осталось дефолтным)
    clients = getGuestsAmountFromUser(); // Запрашиваем с консоли количество гостей 
  }

  // Создаем поток работы админа.
  HotelAdministrator admin = HotelAdministrator(logger);
  pthread_t admin_thread;
  pthread_create(&admin_thread, nullptr, &acceptAndSettleNewGuest, &admin);
  
  // Создаем клиентов и поток для каждого.
  std::vector<Guest> guests(clients);
  std::vector<pthread_t> guest_threads(clients);
  for (int i = 0; i != clients; ++i) {
    guests[i] = getNewGuest(i + 1);
    pthread_create(&guest_threads[i], nullptr, &guestStaying, &guests[i]);
    usleep(100);
  }

  // Дожидаемся окончания работы всех потоков клиентов (вход/выход (в том числе моментальный, если не нашлось свободного номера) всех клиентов)
  for (int i = 0; i != clients; ++i) {
    pthread_join(guest_threads[i], nullptr);
  }

  // Присоединяем поток админа и завершаем работу программы.
  HOTEL_IS_WORKING = false;
  pthread_join(admin_thread, nullptr);
  // Если был открыт файл для записи выходных параметров, он закрывается.
  if (file_output) {
    file_output->close();
  }
  pthread_mutex_destroy(&queue_mutex);
  pthread_mutex_destroy(&logger_mutex);
  // Все потоки завершаются автоматически вместе с самой программой.
  return 0;
}
// Установка аргументов при вводе через командную строку.
void setArgs(int &actions, std::istream *input, int argc, char *argv[]) {
  for (int i = 1; i < argc; ++i) {
    if (strcmp(argv[i], "-c") == 0 && i + 1 < argc) {
      actions = std::atoi(argv[++i]);
      if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
        file_output = new std::ofstream(argv[++i]);
      }
    } else if (strcmp(argv[i], "-i") == 0 && i + 1 < argc) {
      file_input = new std::ifstream(argv[++i]);
    } else if (strcmp(argv[i], "-o") == 0 && i + 1 < argc) {
      file_output = new std::ofstream(argv[++i]);
    }
  }
}
// Чтение имени выхдного файла и количества клиентов из файла.
std::pair<Logger, int> readArgsFromFile() {
  std::string output_file;
  std::getline(*file_input, output_file);
  std::string actions_as_str;
  std::getline(*file_input, actions_as_str);
  int actions = std::stoi(actions_as_str);
  file_input->close();
  file_output = new std::ofstream(output_file);
  return {Logger(output, file_output), actions};
}

int getGuestsAmountFromUser() {
  std::string message = "Enter amount of hotel's guests: ";
  std::cout << message;
  int guests_amount;
  std::cin >> guests_amount;
  return guests_amount;
}
// Обработка пришедших клиентов.
void *acceptAndSettleNewGuest(void *hotel_administrator) {
  auto *admin = static_cast<HotelAdministrator *>(hotel_administrator);

  while (HOTEL_IS_WORKING || !current_actions.empty()) {
    pthread_mutex_lock(&queue_mutex);
    if (!current_actions.empty()) {
      std::pair<Guest, Action> current_action = current_actions.front();
      current_actions.pop();
      pthread_mutex_unlock(&queue_mutex);

      pthread_mutex_lock(&logger_mutex);
      if (current_action.second == Action::COMEIN) {
        Room current_room = admin->guestComming(current_action.first);
        
        // Если комната не найдена (нет удовлетворяющих условию свободных), продолжаем цикл
        if (current_room.number == -1) {
          std::string gender  = current_action.first.gender == Gender::WOMAN ? "woman" : "man";
          std::string message = "Guest " + std::to_string(current_action.first.id) + " (" + gender + ") could not find a room\n";
          admin->log(message);
          pthread_mutex_unlock(&logger_mutex);
          continue; // Пропускаем текущую итерацию
        }
        // Логгирование для входа.
        std::string message = getMessage(current_action.first, Action::COMEIN, current_room);
        admin->log(message);
      } else {
        std::pair<Guest, Room> current_guest_and_room =
            admin->guestLeaving(current_action.first.id);
        
        // Если не удалось найти комнату для выезда
        if (current_guest_and_room.second.number == -1) {
          pthread_mutex_unlock(&logger_mutex);
          continue;
        }
        // Логгирование для выезда.
        std::string message = getMessage(current_guest_and_room.first, Action::COMEOUT, current_guest_and_room.second);
        admin->log(message);
      }
      pthread_mutex_unlock(&logger_mutex);
    } else {
      pthread_mutex_unlock(&queue_mutex);
    }
  }
  return nullptr;
}

void *guestStaying(void *visitor) {
  Guest *guest = static_cast<Guest *>(visitor);
  
  // Запрос на заезд.
  pthread_mutex_lock(&queue_mutex);
  current_actions.push({*guest, Action::COMEIN});
  pthread_mutex_unlock(&queue_mutex);

  usleep(getGuestsStayingTime());

  // Запрос на выезд.
  pthread_mutex_lock(&queue_mutex);
  current_actions.push({*guest, Action::COMEOUT});
  pthread_mutex_unlock(&queue_mutex);

  return nullptr;
}

int getGuestsStayingTime() {
  return GENERATOR(MT);
}

Guest getNewGuest(int id) {
  Guest new_guest;
  new_guest.id = id;
  // Рандомное определение пола.
  new_guest.gender = GENERATOR(MT) % 2 == 0 ? Gender::WOMAN : Gender::MAN;
  return new_guest;
}
// Формирование сообщения для логгирования.
std::string getMessage(Guest &guest, Action action, Room &room) {
  std::string gender  = guest.gender == Gender::WOMAN ? "woman" : "man";
  std::string message = "Guest " + std::to_string(guest.id) + " (" + gender + ") ";
  if (action == Action::COMEIN) {
    message += "checked into";
  } else {
    message += "checked out of";
  }
  message += " the room " + std::to_string(room.number) + "\n";
  return message;
}
