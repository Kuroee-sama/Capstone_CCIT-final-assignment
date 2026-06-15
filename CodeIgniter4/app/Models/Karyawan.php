<?php namespace App\Models;
use CodeIgniter\Model;

class Karyawan extends Model {
    protected $table = 'karyawan';
    protected $primaryKey = 'karyawan_id';
    protected $allowedFields = ['username', 'email', 'password', 'umur', 'alamat', 'tgl_lahir', 'no_telp', 'role'];
}