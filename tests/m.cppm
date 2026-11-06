// m.cppm
module;
#include <typeinfo>

export module m;

template <class T> void detail() {
  (void)typeid(T);
}

export template <class T> void function() {
  detail<T>();
}
