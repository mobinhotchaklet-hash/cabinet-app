
/*
Generated main.dart (MVP) - Persian RTL Flutter app for inventory & invoices.
This file is the same MVP code prepared earlier.
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حسابداری و انبار کابینت',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
        fontFamily: 'Vazir',
      ),
      home: const AuthGate(),
      locale: const Locale('fa'),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData) return const LoginPage();
        return const HomePage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool loading = false;

  Future<void> signIn() async {
    setState(() => loading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailCtl.text.trim(), password: _passCtl.text.trim());
    } catch (e) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _emailCtl.text.trim(), password: _passCtl.text.trim());
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': _emailCtl.text.split('@').first,
          'role': 'seller',
        });
      } catch (e2) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('خطا در ورود: $e2')));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('ورود / ثبت‌نام')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailCtl,
                decoration: const InputDecoration(label: Text('ایمیل')),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _passCtl,
                obscureText: true,
                decoration: const InputDecoration(label: Text('رمز عبور')),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: loading ? null : signIn,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('ورود / ثبت‌نام'),
              ),
              const SizedBox(height: 8),
              const Text('با ورود، همه تغییرات آنلاین و لحظه‌ای همگام‌سازی می‌شوند')
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tab = 0;
  String role = 'seller';
  String name = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      setState(() {
        role = doc.data()!['role'] ?? 'seller';
        name = doc.data()!['name'] ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      InventoryPage(),
      InvoicePage(),
      UsersPage(),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('حسابداری و انبار کابینت'),
          actions: [
            IconButton(
                onPressed: () => FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout)),
          ],
        ),
        body: pages[_tab],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _tab,
          onTap: (i) => setState(() => _tab = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'انبار'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'فاکتورها'),
            BottomNavigationBarItem(icon: Icon(Icons.people), label: 'کاربران'),
          ],
        ),
      ),
    );
  }
}

class InventoryPage extends StatelessWidget {
  InventoryPage({super.key});

  final productsRef = FirebaseFirestore.instance.collection('products');

  Future<void> showAddDialog(BuildContext context, [DocumentSnapshot? doc]) async {
    final nameCtl = TextEditingController(text: doc?.get('name'));
    final unitCtl = TextEditingController(text: doc?.get('unit'));
    final qtyCtl = TextEditingController(text: doc != null ? doc.get('qty').toString() : '0');
    final priceCtl = TextEditingController(text: doc != null ? doc.get('price').toString() : '0');

    await showDialog(
        context: context,
        builder: (_) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: AlertDialog(
              title: Text(doc == null ? 'افزودن کالا' : 'ویرایش کالا'),
              content: SingleChildScrollView(
                child: Column(children: [
                  TextField(controller: nameCtl, decoration: const InputDecoration(label: Text('نام کالا'))),
                  TextField(controller: unitCtl, decoration: const InputDecoration(label: Text('واحد (مثلاً ورق، متر)'))),
                  TextField(controller: qtyCtl, decoration: const InputDecoration(label: Text('تعداد/مقدار')), keyboardType: TextInputType.number),
                  TextField(controller: priceCtl, decoration: const InputDecoration(label: Text('قیمت فروش واحدی')), keyboardType: TextInputType.number),
                ]),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('انصراف')),
                ElevatedButton(
                    onPressed: () async {
                      final data = {
                        'name': nameCtl.text.trim(),
                        'unit': unitCtl.text.trim(),
                        'qty': double.tryParse(qtyCtl.text.trim()) ?? 0.0,
                        'price': double.tryParse(priceCtl.text.trim()) ?? 0.0,
                        'createdAt': FieldValue.serverTimestamp(),
                      };
                      if (doc == null) {
                        await productsRef.add(data);
                      } else {
                        await productsRef.doc(doc.id).update(data);
                      }
                      Navigator.pop(context);
                    },
                    child: const Text('ذخیره'))
              ],
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: productsRef.orderBy('name').snapshots(),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        final docs = snap.data!.docs;
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () => showAddDialog(context),
              child: const Icon(Icons.add),
            ),
            body: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final d = docs[i];
                final name = d.get('name');
                final unit = d.get('unit');
                final qty = d.get('qty');
                final price = d.get('price');
                return Card(
                  child: ListTile(
                    title: Text(name),
                    subtitle: Text('موجودی: $qty  $unit\nقیمت فروش: ${NumberFormat('#,##0','fa').format(price)}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (v) async {
                        if (v == 'edit') await showAddDialog(context, d);
                        if (v == 'inc') {
                          await productsRef.doc(d.id).update({'qty': FieldValue.increment(1)});
                        }
                        if (v == 'dec') {
                          await productsRef.doc(d.id).update({'qty': FieldValue.increment(-1)});
                        }
                        if (v == 'delete') {
                          await productsRef.doc(d.id).delete();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('ویرایش')),
                        PopupMenuItem(value: 'inc', child: Text('افزایش 1')),
                        PopupMenuItem(value: 'dec', child: Text('کاهش 1')),
                        PopupMenuItem(value: 'delete', child: Text('حذف')),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class InvoicePage extends StatefulWidget {
  InvoicePage({super.key});

  final productsRef = FirebaseFirestore.instance.collection('products');
  final invoicesRef = FirebaseFirestore.instance.collection('invoices');

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  List<Map<String, dynamic>> cart = [];
  String discountType = 'percent';
  double discountValue = 0.0;

  void addToCart(DocumentSnapshot p) {
    final existing = cart.indexWhere((e) => e['productId'] == p.id);
    if (existing >= 0) {
      cart[existing]['qty'] = cart[existing]['qty'] + 1;
    } else {
      cart.add({
        'productId': p.id,
        'name': p.get('name'),
        'unit': p.get('unit'),
        'qty': 1.0,
        'unitPrice': (p.get('price') as num).toDouble(),
      });
    }
    setState(() {});
  }

  double get subtotal => cart.fold(0.0, (s, e) => s + (e['qty'] * e['unitPrice']));

  double get total {
    double sub = subtotal;
    if (discountType == 'percent') {
      return sub - sub * (discountValue / 100.0);
    } else {
      return sub - discountValue;
    }
  }

  Future<void> createInvoice() async {
    if (cart.isEmpty) return;
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = {
      'createdBy': uid,
      'createdAt': FieldValue.serverTimestamp(),
      'items': cart.map((e) => {
            'productId': e['productId'],
            'name': e['name'],
            'unit': e['unit'],
            'qty': e['qty'],
            'unitPrice': e['unitPrice']
          }).toList(),
      'subtotal': subtotal,
      'discountType': discountType,
      'discountValue': discountValue,
      'total': total,
    };
    final ref = await FirebaseFirestore.instance.collection('invoices').add(doc);

    final batch = FirebaseFirestore.instance.batch();
    for (var item in cart) {
      final prodRef = FirebaseFirestore.instance.collection('products').doc(item['productId']);
      batch.update(prodRef, {'qty': FieldValue.increment(-item['qty'])});
    }
    await batch.commit();

    setState(() {
      cart.clear();
      discountValue = 0.0;
      discountType = 'percent';
    });

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فاکتور صادر شد')));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: widget.productsRef.orderBy('name').snapshots(),
                      builder: (context, snap) {
                        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                        final docs = snap.data!.docs;
                        return ListView.builder(
                          itemCount: docs.length,
                          itemBuilder: (context, i) {
                            final d = docs[i];
                            return ListTile(
                              title: Text(d.get('name')),
                              subtitle: Text('موجودی: ${d.get('qty')}  ${d.get('unit')} - قیمت: ${NumberFormat('#,##0','fa').format(d.get('price'))}'),
                              trailing: ElevatedButton(
                                onPressed: () => addToCart(d),
                                child: const Text('افزودن'),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            VerticalDivider(width: 1),
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Text('سبد خرید', style: Theme.of(context).textTheme.titleLarge),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (context, i) {
                        final it = cart[i];
                        return ListTile(
                          title: Text(it['name']),
                          subtitle: Text('تعداد: ${it['qty']} ${it['unit']} - قیمت واحد: ${NumberFormat('#,##0','fa').format(it['unitPrice'])}'),
                          trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    it['qty'] = (it['qty'] - 1).clamp(0.0, double.infinity);
                                    if (it['qty'] == 0) cart.removeAt(i);
                                  });
                                },
                                icon: const Icon(Icons.remove)),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    it['qty'] = it['qty'] + 1;
                                  });
                                },
                                icon: const Icon(Icons.add)),
                          ]),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(children: [
                          const Text('نوع تخفیف:'),
                          const SizedBox(width: 8),
                          DropdownButton<String>(
                            value: discountType,
                            items: const [
                              DropdownMenuItem(value: 'percent', child: Text('درصد')),
                              DropdownMenuItem(value: 'amount', child: Text('مبلغ')),
                            ],
                            onChanged: (v) => setState(() => discountType = v!),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextField(
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(label: Text('مقدار تخفیف')),
                              onChanged: (v) => setState(() => discountValue = double.tryParse(v) ?? 0.0),
                            ),
                          )
                        ]),
                        const SizedBox(height: 8),
                        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Text('جمع جزء: ${NumberFormat('#,##0','fa').format(subtotal)}'),
                          ElevatedButton(onPressed: createInvoice, child: const Text('صدور فاکتور'))
                        ]),
                        const SizedBox(height: 8),
                        Text('مبلغ نهایی: ${NumberFormat('#,##0','fa').format(total)}')
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class UsersPage extends StatelessWidget {
  UsersPage({super.key});

  final usersRef = FirebaseFirestore.instance.collection('users');

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream: usersRef.snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) return const Center(child: CircularProgressIndicator());
            final docs = snap.data!.docs;
            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final d = docs[i];
                return ListTile(
                  title: Text(d.get('name') ?? d.id),
                  subtitle: Text('نقش: ${d.get('role') ?? 'seller'}'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (v) async {
                      if (v == 'seller' || v == 'accountant' || v == 'owner') {
                        await usersRef.doc(d.id).update({'role': v});
                      }
                      if (v == 'delete') await usersRef.doc(d.id).delete();
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: 'seller', child: Text('فروشنده')),
                      PopupMenuItem(value: 'accountant', child: Text('حسابدار')),
                      PopupMenuItem(value: 'owner', child: Text('مالک')),
                      PopupMenuItem(value: 'delete', child: Text('حذف')),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
