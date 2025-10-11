abstract class KategoriEvent {}

class FetchKategori extends KategoriEvent {}

class AddKategori extends KategoriEvent {
  final String namaKategori;

  AddKategori(this.namaKategori);
}

class EditKategori extends KategoriEvent {
  final String idKategori;
  final String namaBaru;

  EditKategori(this.idKategori, this.namaBaru);
}
