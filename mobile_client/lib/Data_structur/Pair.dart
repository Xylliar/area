class Pair<T, U> {
  T first;
  U _second; // Private field to back the second property

  Pair(this.first, this._second);

  U get second => _second;

  set second(U value) {
    _second = value;
  }
}