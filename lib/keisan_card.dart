class KeisanCard {
  KeisanCard(this.multiplier, this.multiplicand);
  // かける数
  int multiplier;
  // かけられる数
  int multiplicand;
  // 答え
  int get answer => multiplier * multiplicand;
}
