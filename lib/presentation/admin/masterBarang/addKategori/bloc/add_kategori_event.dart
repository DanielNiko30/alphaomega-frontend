abstract class KategoriEvent {}

class FetchKategori extends KategoriEvent {}

class AddKategori extends KategoriEvent {
  final String namaKategori;

  AddKategori(this.namaKategori);
}
