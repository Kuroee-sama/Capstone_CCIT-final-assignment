<?php namespace App\Models;
use CodeIgniter\Model;

class Kategori extends Model {
    protected $table = 'kategori';
    protected $primaryKey = 'kategori_id';
    protected $allowedFields = ['nama_kategori', 'k_description'];
}
