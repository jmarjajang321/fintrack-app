import 'package:flutter/material.dart';

void main() {
  runApp(const DompetKuApp());
}

class DompetKuApp extends StatelessWidget {
  const DompetKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FinTrack All-in-One',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.light),
        useMaterial3: true,
      ),
      home: const MainDashboard(),
    );
  }
}

// --- MODEL DATA ---
class Account {
  String name;
  String type; // 'Bank' atau 'E-Wallet'
  double balance;
  Account({required this.name, required this.type, required this.balance});
}

class TransactionItem {
  String title;
  double amount;
  bool isIncome;
  String accountName;
  DateTime date;
  TransactionItem({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.accountName,
    required this.date,
  });
}

class DebtItem {
  String name;
  double totalAmount;
  double paidAmount;
  double monthlyInstallment;
  DebtItem({
    required this.name,
    required this.totalAmount,
    required this.paidAmount,
    required this.monthlyInstallment,
  });
}

class InvestmentItem {
  String name;
  String category; // 'Saham', 'Obligasi', 'Kripto', 'Lainnya'
  double value;
  InvestmentItem({required this.name, required this.category, required this.value});
}

// --- MAIN SCREEN ---
class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  // Data Awal (Contoh)
  final List<Account> _accounts = [
    Account(name: 'BCA', type: 'Bank', balance: 8500000),
    Account(name: 'GoPay', type: 'E-Wallet', balance: 650000),
    Account(name: 'OVO', type: 'E-Wallet', balance: 350000),
  ];

  final List<TransactionItem> _transactions = [
    TransactionItem(title: 'Gaji Bulanan', amount: 10000000, isIncome: true, accountName: 'BCA', date: DateTime.now()),
    TransactionItem(title: 'Makan & Kopi', amount: 150000, isIncome: false, accountName: 'GoPay', date: DateTime.now()),
    TransactionItem(title: 'Belanja Bulanan', amount: 850000, isIncome: false, accountName: 'BCA', date: DateTime.now()),
  ];

  final List<DebtItem> _debts = [
    DebtItem(name: 'Cicilan HP / Paylater', totalAmount: 6000000, paidAmount: 2000000, monthlyInstallment: 500000),
    DebtItem(name: 'Kredit Motor', totalAmount: 18000000, paidAmount: 6000000, monthlyInstallment: 1000000),
  ];

  final List<InvestmentItem> _investments = [
    InvestmentItem(name: 'BBCA', category: 'Saham', value: 12000000),
    InvestmentItem(name: 'SBR013', category: 'Obligasi', value: 10000000),
    InvestmentItem(name: 'Bitcoin (BTC)', category: 'Kripto', value: 5000000),
  ];

  // Helper perhitungan
  double get totalCash => _accounts.fold(0, (sum, item) => sum + item.balance);
  double get totalInvestments => _investments.fold(0, (sum, item) => sum + item.value);
  double get totalRemainingDebt => _debts.fold(0, (sum, item) => sum + (item.totalAmount - item.paidAmount));
  double get netWorth => (totalCash + totalInvestments) - totalRemainingDebt;

  double get totalIncome => _transactions.where((t) => t.isIncome).fold(0, (sum, t) => sum + t.amount);
  double get totalExpense => _transactions.where((t) => !t.isIncome).fold(0, (sum, t) => sum + t.amount);

  String formatRp(double val) {
    return 'Rp ${val.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}';
  }

  // --- DIALOG TAMBAH REKENING / E-WALLET ---
  void _showAddAccountDialog() {
    final nameCtrl = TextEditingController();
    final balCtrl = TextEditingController();
    String selectedType = 'Bank';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Bank / E-Wallet'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama (cth: Mandiri, Dana, ShopeePay)')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedType,
                items: ['Bank', 'E-Wallet'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setDialogState(() => selectedType = val!),
                decoration: const InputDecoration(labelText: 'Jenis Akun'),
              ),
              const SizedBox(height: 10),
              TextField(controller: balCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Saldo Awal (Rp)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _accounts.add(Account(
                      name: nameCtrl.text,
                      type: selectedType,
                      balance: double.tryParse(balCtrl.text) ?? 0,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG TAMBAH TRANSAKSI ---
  void _showAddTransactionDialog() {
    if (_accounts.isEmpty) return;
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    bool isIncome = false;
    Account selectedAcc = _accounts.first;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Catat Transaksi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('Pengeluaran')),
                  ButtonSegment(value: true, label: Text('Pemasukan')),
                ],
                selected: {isIncome},
                onSelectionChanged: (val) => setDialogState(() => isIncome = val.first),
              ),
              const SizedBox(height: 10),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Keterangan')),
              TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nominal (Rp)')),
              const SizedBox(height: 10),
              DropdownButtonFormField<Account>(
                value: selectedAcc,
                items: _accounts.map((a) => DropdownMenuItem(value: a, child: Text('${a.name} (${a.type})'))).toList(),
                onChanged: (val) => setDialogState(() => selectedAcc = val!),
                decoration: const InputDecoration(labelText: 'Pilih Rekening / E-Wallet'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                final amt = double.tryParse(amountCtrl.text) ?? 0;
                if (titleCtrl.text.isNotEmpty && amt > 0) {
                  setState(() {
                    _transactions.insert(0, TransactionItem(
                      title: titleCtrl.text,
                      amount: amt,
                      isIncome: isIncome,
                      accountName: selectedAcc.name,
                      date: DateTime.now(),
                    ));
                    selectedAcc.balance += isIncome ? amt : -amt;
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  // --- DIALOG TAMBAH UTANG / CICILAN ---
  void _showAddDebtDialog() {
    final nameCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final monthlyCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Utang / Cicilan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Tanggungan (cth: SpayLater, KPR)')),
            TextField(controller: totalCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Total Utang (Rp)')),
            TextField(controller: monthlyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Cicilan per Bulan (Rp)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              if (nameCtrl.text.isNotEmpty) {
                setState(() {
                  _debts.add(DebtItem(
                    name: nameCtrl.text,
                    totalAmount: double.tryParse(totalCtrl.text) ?? 0,
                    paidAmount: 0,
                    monthlyInstallment: double.tryParse(monthlyCtrl.text) ?? 0,
                  ));
                });
                Navigator.pop(ctx);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // --- DIALOG TAMBAH INVESTASI ---
  void _showAddInvestmentDialog() {
    final nameCtrl = TextEditingController();
    final valCtrl = TextEditingController();
    String selectedCat = 'Saham';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Tambah Aset Investasi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Aset (cth: BBCA, SBN, Bitcoin)')),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCat,
                items: ['Saham', 'Obligasi', 'Kripto', 'Reksadana', 'Emas'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: (val) => setDialogState(() => selectedCat = val!),
                decoration: const InputDecoration(labelText: 'Jenis Instrumen'),
              ),
              TextField(controller: valCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Nilai Saat Ini (Rp)')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
            FilledButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  setState(() {
                    _investments.add(InvestmentItem(
                      name: nameCtrl.text,
                      category: selectedCat,
                      value: double.tryParse(valCtrl.text) ?? 0,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildAccountsAndTransactionsTab(),
      _buildDebtTab(),
      _buildInvestmentTab(),
      _buildAnalyticsTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('FinTrack All-in-One', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) => setState(() => _selectedIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.account_balance_wallet), label: 'Dompet'),
          NavigationDestination(icon: Icon(Icons.credit_card), label: 'Cicilan'),
          NavigationDestination(icon: Icon(Icons.trending_up), label: 'Investasi'),
          NavigationDestination(icon: Icon(Icons.pie_chart), label: 'Analisis'),
        ],
      ),
    );
  }

  // TAB 1: REKENING & TRANSAKSI
  Widget _buildAccountsAndTransactionsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Rekening Bank & E-Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            TextButton.icon(onPressed: _showAddAccountDialog, icon: const Icon(Icons.add), label: const Text('Tambah Akun')),
          ],
        ),
        ..._accounts.map((acc) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Icon(acc.type == 'Bank' ? Icons.account_balance : Icons.phone_android)),
            title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(acc.type),
            trailing: Text(formatRp(acc.balance), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        )),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Riwayat Transaksi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FilledButton.icon(onPressed: _showAddTransactionDialog, icon: const Icon(Icons.add), label: const Text('Catat')),
          ],
        ),
        const SizedBox(height: 8),
        ..._transactions.map((tx) => ListTile(
          leading: Icon(tx.isIncome ? Icons.arrow_downward : Icons.arrow_upward, color: tx.isIncome ? Colors.green : Colors.red),
          title: Text(tx.title),
          subtitle: Text(tx.accountName),
          trailing: Text(
            '${tx.isIncome ? "+" : "-"} ${formatRp(tx.amount)}',
            style: TextStyle(color: tx.isIncome ? Colors.green : Colors.red, fontWeight: FontWeight.bold),
          ),
        )),
      ],
    );
  }

  // TAB 2: UTANG & CICILAN
  Widget _buildDebtTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Total Sisa Tanggungan / Utang'),
                Text(formatRp(totalRemainingDebt), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daftar Cicilan Aktif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FilledButton.icon(onPressed: _showAddDebtDialog, icon: const Icon(Icons.add), label: const Text('Tambah Utang')),
          ],
        ),
        const SizedBox(height: 8),
        ..._debts.map((d) {
          final progress = (d.paidAmount / d.totalAmount).clamp(0.0, 1.0);
          final remaining = d.totalAmount - d.paidAmount;
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(d.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Sisa: ${formatRp(remaining)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(value: progress, minHeight: 8),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Cicilan: ${formatRp(d.monthlyInstallment)} / bln'),
                      TextButton(
                        onPressed: remaining > 0 ? () {
                          setState(() {
                            d.paidAmount = (d.paidAmount + d.monthlyInstallment).clamp(0, d.totalAmount);
                          });
                        } : null,
                        child: const Text('Bayar 1x Cicilan'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // TAB 3: INVESTASI
  Widget _buildInvestmentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Total Nilai Portofolio Investasi'),
                Text(formatRp(totalInvestments), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Daftar Aset Investasi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            FilledButton.icon(onPressed: _showAddInvestmentDialog, icon: const Icon(Icons.add), label: const Text('Tambah Aset')),
          ],
        ),
        const SizedBox(height: 8),
        ..._investments.map((inv) => Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(inv.category.substring(0, 2).toUpperCase())),
            title: Text(inv.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(inv.category),
            trailing: Text(formatRp(inv.value), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
          ),
        )),
      ],
    );
  }

  // TAB 4: GRAFIK & ANALISIS KEUANGAN
  Widget _buildAnalyticsTab() {
    final maxFlow = (totalIncome > totalExpense ? totalIncome : totalExpense);
    final incRatio = maxFlow > 0 ? totalIncome / maxFlow : 0.0;
    final expRatio = maxFlow > 0 ? totalExpense / maxFlow : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Kekayaan Bersih (Net Worth)', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 4),
                Text(formatRp(netWorth), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.indigo)),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(children: [const Text('Kas & E-Wallet'), Text(formatRp(totalCash), style: const TextStyle(fontWeight: FontWeight.bold))]),
                    Column(children: [const Text('Investasi'), Text(formatRp(totalInvestments), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green))]),
                    Column(children: [const Text('Utang'), Text(formatRp(totalRemainingDebt), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red))]),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text('Grafik Pemasukan vs Pengeluaran', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total Pemasukan: ${formatRp(totalIncome)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: incRatio, minHeight: 14, color: Colors.green, backgroundColor: Colors.grey.shade200),
                const SizedBox(height: 16),
                Text('Total Pengeluaran: ${formatRp(totalExpense)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: expRatio, minHeight: 14, color: Colors.red, backgroundColor: Colors.grey.shade200),
                const SizedBox(height: 16),
                Text(
                  'Selisih Arus Kas: ${formatRp(totalIncome - totalExpense)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
