class UpdateProductQuantity {
  final String oid;
  final String pid;
  final String size;
  final int newQuantity;

  UpdateProductQuantity({
    required this.oid,
    required this.pid,
    required this.size,
    required this.newQuantity,
  });

  @override
  String toString() {
    return 'OrderDetail(productId: $pid, size: $size, newQuantity: $newQuantity)';
  }
}