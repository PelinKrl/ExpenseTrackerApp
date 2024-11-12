import 'package:expensetracker/auth/auth_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/barGraph/bar_graph.dart';
import 'package:expensetracker/components/my_list_tile.dart';
import 'package:expensetracker/models/expense.dart';
import 'package:expensetracker/database/expense_db.dart';
import 'package:expensetracker/util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController amountController = TextEditingController();

  // futures to load graph data & monthly total
  Future<Map<String,double>>? _monthlyTotalsFuture;
  Future<double>? _calculateCurrentMonthTotal;

  @override
  void initState() {
    super.initState();

    // Call the Provider after the widget is fully initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ExpenseDatabase>(context, listen: false).readExpenses();
    });

    refreshData();
  }

  //refresh  data

  Future<void> refreshData()async{
    await Provider.of<ExpenseDatabase>(context,listen: false).readExpenses();

    setState(() {
      _monthlyTotalsFuture = Provider.of<ExpenseDatabase>(context,listen:false).calculateMonthlyTotals();

    _calculateCurrentMonthTotal = Provider.of<ExpenseDatabase>(context,listen: false).calculateCurrentMonthTotal();
    });
  }

  // Open new expense box
  void openNewExpenseBox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("New Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User input -> expense name
            TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            // User input -> amount
            TextField(
              controller: amountController,
              decoration: const InputDecoration(hintText: 'Amount'),
            ),
          ],
        ),
        actions: [
          // Cancel button
          _cancelButton(),
          // Save button
          _saveButton(),
        ],
      ),
    );
  }

  //Open delete box
  void openDeleteBox(Expense expense){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Expense"),
        
        actions: [
          // Cancel button
          _cancelButton(),
          // Save button
          _deleteButton(expense.id!),
        ],
      ),
    );
  }

  //open edit box
  void openEditBox(Expense expense){
    //pre fill existing values into textfields
    String existingName=expense.name;
    String existingAmount=expense.amount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Expense"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User input -> expense name
            TextField(
              controller: nameController,
              decoration: InputDecoration(hintText: existingName),
            ),
            // User input -> amount
            TextField(
              controller: amountController,
              decoration: InputDecoration(hintText: existingAmount),
            ),
          ],
        ),
        actions: [
          // Cancel button
          _cancelButton(),
          // Save button
          _editExpenseButton(expense),
        ],
      ),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseDatabase>(
      builder: (context, value, child) {

        //get dates
        int startMonth = value.getStartMonth();
        int startYear = value.getStartYear();
        int currentMonth = DateTime.now().month;
        int currentYear = DateTime.now().year;

        //calculate the number of months since the first month
        int monthCount =calculateMonthCount(startYear,startMonth,currentYear,currentMonth);

        //only display the expenses for the current month
        List<Expense> currentMonthExpense = value.allExpenses.where((expense){
          return expense.date.year ==currentYear && expense.date.month==currentMonth;
        }).toList();

        //return UI
        return Scaffold(
        backgroundColor: Colors.grey.shade300,
        floatingActionButton: FloatingActionButton(
          onPressed: openNewExpenseBox,
          child: const Icon(Icons.add),
        ),

        //APPBAR
                appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.purple.shade100, // Set the AppBar background color
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(20.0), // Rounded corners
              ),
             
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Total amount
                    FutureBuilder<double>(
                      future: _calculateCurrentMonthTotal,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done) {
                          return Text(
                            '₺${snapshot.data!.toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                          );
                        } else {
                          return const Text("Loading...");
                        }
                      },
                    ),
                    // Current month
                    Text(
                      getCurrentMonthName(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 50.0),
              //GRAPH UI

              SizedBox(
                height: 250,
                child: FutureBuilder(future: _monthlyTotalsFuture, builder: (context,snapShot){
                  //data is loaded
                  if(snapShot.connectionState == ConnectionState.done){
                    Map<String,double> monthlyTotals= snapShot.data ?? {};
                
                    //create the list of monthly summary
                    List<double> monthlySummary=List.generate(monthCount,(index){
                      //calculate year-month considering start month &index
                      int year = startYear +(startMonth+index-1)~/12;
                      int month = (startMonth + index -1)%12 +1;

                      //create the key in the format of year-month
                      String yearMonthKey ='$year-$month';

                      //return total for year-month or 0.0 if doesnot exist
                      return monthlyTotals[yearMonthKey] ?? 0.0;
                    },);
                
                    return MyBarGraph(monthlySummary: monthlySummary, startMonth: startMonth);
                  }
                
                  //loading..
                  else{
                    return const Center(child: Text("Loading..."),);
                  }
                
                }),
              ),
              const SizedBox(height: 25,),
          
              //EXPENSE LIST UI
              Expanded(
                child: ListView.builder(
                  itemCount: currentMonthExpense.length,
                  itemBuilder: (context, index) {

                    //reverse the index to show last item first
                    int reversedIndex = currentMonthExpense.length-1-index;

                    // Get individual expense
                    Expense individualExpense = currentMonthExpense[reversedIndex];
                
                    // Return list tile UI
                return MyListTile(
                  title: individualExpense.name,
                  trailing: formatAmount(individualExpense.amount,),
                  onEditPressed: (context)=>openEditBox(individualExpense),
                  onDeletePressed: (context)=>openDeleteBox(individualExpense),
                );
                          },
                        ),
              ),
Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                children: [
                  Icon(Icons.person, color: Colors.deepPurple),
                  const SizedBox(height: 8),
                  Text(
                    FirebaseAuth.instance.currentUser?.email ?? 'No Email',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.deepPurple),
                onPressed: () {
                    FirebaseAuth.instance.signOut().then((_) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => AuthPage()),
      (route) => false,
    );
  });
                },
              ),
            ],
          ),
        ),
      ),
            ],
          ),
        ),
      );
      } ,
    );
  }

  // CANCEL BUTTON
  Widget _cancelButton() {
    return MaterialButton(
      onPressed: () {
        // Pop box
        Navigator.pop(context);

        // Clear controllers
        nameController.clear();
        amountController.clear();
      },
      child: const Text('Cancel'),
    );
  }

  // SAVE BUTTON
  Widget _saveButton() {
    return MaterialButton(
      onPressed: () async {
        if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
          // Pop box
          Navigator.pop(context);
          String userId = FirebaseAuth.instance.currentUser!.uid;
          // Create new expense
          Expense newExpense = Expense(
            userId: userId,
            name: nameController.text,
            amount: convertStringToDouble(amountController.text),
            date: DateTime.now(),
          );

          // Save to db
          await Provider.of<ExpenseDatabase>(context, listen: false)
              .addExpense(newExpense);
          
          refreshData();

          // Clear controllers
          nameController.clear();
          amountController.clear();
        }
      },
      child: const Text('Save'),
    );
  }

  // EDIT EXPENSE BUTTON
  Widget _editExpenseButton(Expense expense) {
  final userId = FirebaseAuth.instance.currentUser?.uid; // Get the current user's ID
  
  return MaterialButton(
    onPressed: () async {
      // Save as long as at least one text field has been changed
      if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
        // Pop box
        Navigator.pop(context);
        String userId = FirebaseAuth.instance.currentUser!.uid;
        // Create a new updated expense with userId
        Expense updatedExpense = Expense(

          id: expense.id,
          userId: userId,  // Include userId here
          name: nameController.text.isNotEmpty ? nameController.text : expense.name,
          amount: amountController.text.isNotEmpty ? convertStringToDouble(amountController.text) : expense.amount,
          date: DateTime.now(),
        );

        // Save to db
        await Provider.of<ExpenseDatabase>(context, listen: false).updateExpense(updatedExpense);
        refreshData();

        // Clear text fields
        nameController.clear();
        amountController.clear();
      }
    },
    child: const Text("Save"),
  );
}


  // DELETE BUTTON
  Widget _deleteButton(String id){
    return MaterialButton(
      onPressed:()async{
      //pop the box
      Navigator.pop(context);

      //delete expense
      await Provider.of<ExpenseDatabase>(context, listen: false).deleteExpense(id);

      refreshData();

      //clear fields
      nameController.clear();
      amountController.clear();
     },
     child: Text("Delete"),
    );   
  }
}
