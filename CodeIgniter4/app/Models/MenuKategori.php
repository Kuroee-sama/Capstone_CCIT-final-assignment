<?php namespace App\Models;
use CodeIgniter\Model;

class MenuKategori extends Model {
    protected $table = 'menu_kategori';
    protected $primaryKey = ['menu_id', 'kategori_id'];
    protected $allowedFields = ['menu_id', 'kategori_id'];
    protected $useAutoIncrement = false;
}
