#include <iostream>
#include "hotel.h"
#include <ostream>
#include <pthread.h>
#include <random>
#include <string>
#include <queue>
#ifndef MAIN_H
#define MAIN_H

const int DEFAULT_CLIENTS_AMOUNT = 0;

bool HOTEL_IS_WORKING = true;

std::queue<std::pair<Guest, Action> > current_actions;
pthread_mutex_t queue_mutex = PTHREAD_MUTEX_INITIALIZER;
pthread_mutex_t logger_mutex = PTHREAD_MUTEX_INITIALIZER;

const int MIN_VALUE = 5000;
const int MAX_VALUE = 7000;
std::random_device RD;
std::mt19937 MT(RD());
std::uniform_int_distribution<int> GENERATOR =
    std::uniform_int_distribution<int>(MIN_VALUE, MAX_VALUE);

std::istream *input = &std::cin;
std::ifstream *file_input = nullptr;
std::ostream *output = &std::cout;
std::ofstream *file_output = nullptr;

void setArgs(int &, std::istream *, int, char *[]);
std::pair<Logger, int> readArgsFromFile();
int getGuestsAmountFromUser();
void *acceptAndSettleNewGuest(void *);
void *guestStaying(void *);
int getGuestsStayingTime();
Guest getNewGuest(int);
std::string getMessage(Guest &, Action, Room &);
#endif