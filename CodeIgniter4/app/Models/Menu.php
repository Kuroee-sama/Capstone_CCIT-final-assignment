<?php namespace App\Models;
use CodeIgniter\Model;

class Menu extends Model {
    protected $table = 'menu';
    protected $primaryKey = 'menu_id';
    protected $allowedFields = ['nama_item', 'harga', 'm_description', 'gambar', 'stok', 'kategori_id'];
}