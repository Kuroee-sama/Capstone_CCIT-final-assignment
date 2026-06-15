<?php

namespace App\Database\Migrations;

use CodeIgniter\Database\Migration;

class AddAuthFieldsToKaryawan extends Migration
{
    public function up()
    {
        $fields = [
            'email' => [
                'type'       => 'VARCHAR',
                'constraint' => 100,
                'unique'     => true,
                'after'      => 'nama',
            ],
            'password' => [
                'type'       => 'VARCHAR',
                'constraint' => 255,
                'after'      => 'email',
            ],
            'role' => [
                'type'       => 'ENUM',
                'constraint' => ['admin', 'kasir', 'manajer'],
                'default'    => 'kasir',
                'after'      => 'password',
            ],
        ];

        $this->forge->addColumn('karyawan', $fields);
    }

    public function down()
    {
        $this->forge->dropColumn('karyawan', ['email', 'password', 'role']);
    }
}
