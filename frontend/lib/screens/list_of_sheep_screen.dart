import 'package:flutter/material.dart';
import '../models/sheep_model.dart';
import '../services/sheep_service.dart';
import 'sheep_profile_screen.dart';

class ListOfSheepScreen extends StatefulWidget {
  const ListOfSheepScreen({super.key});

  @override
  _ListOfSheepScreenState createState() => _ListOfSheepScreenState();
}

class _ListOfSheepScreenState extends State<ListOfSheepScreen> {
  final SheepService _sheepService = SheepService();
  final List<Sheep> _sheepList = [];
  List<Sheep> _filteredSheepList = [];
  final TextEditingController _necklaceIDController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _healthStatusController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = false;
  bool _isVaccinated = false;

  @override
  void initState() {
    super.initState();
    _fetchSheepList();
    _filteredSheepList = _sheepList;
    _searchController.addListener(_filterSheepList);
  }

  @override
  void dispose() {
    _necklaceIDController.dispose();
    _ageController.dispose();
    _raceController.dispose();
    _healthStatusController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  // Fetch the sheep list
  Future<void> _fetchSheepList() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Sheep> fetchedList = await _sheepService.fetchSheep();
      print(fetchedList);
      setState(() {
        _sheepList.clear();
        _sheepList.addAll(fetchedList);
        _filteredSheepList = List.from(_sheepList);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching sheep list: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterSheepList() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSheepList = _sheepList
          .where((sheep) =>
              sheep.necklaceID.toLowerCase().contains(query)) // Filter logic
          .toList();
    });
  }

  // Function to submit sheep details
  Future<void> _submitSheepDetails() async {
    if (_necklaceIDController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _raceController.text.isEmpty ||
        _healthStatusController.text.isEmpty ||
        _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Sheep newSheep = Sheep(
        id: DateTime.now().toString(),
        necklaceID: _necklaceIDController.text,
        age: _ageController.text,
        race: _raceController.text,
        healthStatus: _healthStatusController.text,
        weight: _weightController.text,
        vaccinated: _isVaccinated,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _sheepService.addSheep(newSheep);

      setState(() {
        _sheepList.add(newSheep);
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sheep added successfully!')),
      );

      // Clear fields
      _necklaceIDController.clear();
      _ageController.clear();
      _raceController.clear();
      _healthStatusController.clear();
      _weightController.clear();
      setState(() {
        _isVaccinated = false; // Reset vaccination status after submitting
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding sheep: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });

      // Close the dialog after adding the sheep
      Navigator.of(context).pop();
    }
  }

  // Function to show the "Add Sheep" dialog
  void _showAddSheepDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Sheep'),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _necklaceIDController,
                    decoration: const InputDecoration(
                      labelText: 'Necklace ID',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _raceController,
                    decoration: const InputDecoration(
                      labelText: 'Race',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _healthStatusController,
                    decoration: const InputDecoration(
                      labelText: 'Health Status',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isVaccinated,
                        activeColor: Colors.orange,
                        onChanged: (bool? value) {
                          setState(() {
                            _isVaccinated = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      const Text(
                        'Vaccinated',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 30,
                            ),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                            backgroundColor: Colors.orange,
                          ),
                          onPressed: _submitSheepDetails,
                          child: const Text(
                            'Add Sheep',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  //Delete a sheep

  Future<void> _deleteSheep(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _sheepService.deleteSheep(id);
      setState(() {
        _sheepList.removeWhere((sheep) => sheep.id == id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sheep deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete sheep: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

//Update Sheep
  Future<void> _updateSheepDetails(String id) async {
    if (_necklaceIDController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _raceController.text.isEmpty ||
        _healthStatusController.text.isEmpty ||
        _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Sheep updatedSheep = Sheep(
        id: id,
        necklaceID: _necklaceIDController.text,
        age: _ageController.text,
        race: _raceController.text,
        healthStatus: _healthStatusController.text,
        weight: _weightController.text,
        vaccinated: _isVaccinated,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _sheepService.updateSheep(id, updatedSheep);

      setState(() {
        int index = _sheepList.indexWhere((sheep) => sheep.id == id);
        if (index != -1) {
          _sheepList[index] = updatedSheep;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sheep updated successfully!')),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating sheep: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUpdateSheepDialog(Sheep sheep) {
    // Pre-fill the text fields with the selected sheep's data
    _necklaceIDController.text = sheep.necklaceID;
    _ageController.text = sheep.age;
    _raceController.text = sheep.race;
    _healthStatusController.text = sheep.healthStatus;
    _weightController.text = sheep.weight;
    _isVaccinated = sheep.vaccinated;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Sheep'),
          content: SizedBox(
            width: 350,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _necklaceIDController,
                    decoration: const InputDecoration(
                      labelText: 'Necklace ID',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _raceController,
                    decoration: const InputDecoration(
                      labelText: 'Race',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _healthStatusController,
                    decoration: const InputDecoration(
                      labelText: 'Health Status',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextField(
                    controller: _weightController,
                    decoration: const InputDecoration(
                      labelText: 'Weight',
                      floatingLabelStyle: TextStyle(color: Colors.orange),
                      // border: OutlineInputBorder(),

                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isVaccinated,
                        activeColor: Colors.orange,
                        onChanged: (bool? value) {
                          setState(() {
                            _isVaccinated = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(
                        width: 4.0,
                      ),
                      const Text('Vaccinated'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 30,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                  horizontal: 30,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                backgroundColor: Colors.orange,
              ),
              onPressed: () => _updateSheepDetails(sheep.id),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List of Sheep')),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: 350,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.orange,
                    ),
                    labelText: 'Search By Necklace',
                    floatingLabelStyle: TextStyle(color: Colors.orange),
                    // border: OutlineInputBorder(),

                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange)),
                  ),
                ),
              ),
            ),
            Container(
              child: const Text(
                "Cheep List",
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            _isLoading
                ? const CircularProgressIndicator()
                : _sheepList.isEmpty
                    ? const Text('No sheep found')
                    : Expanded(
                        child: SingleChildScrollView(
                        child: DataTable(
                          columns: const [
                            DataColumn(
                                label: Text(
                              'Necklace',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 4, 2, 11)),
                            )),
                            DataColumn(
                                label: Text('Age',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(
                                label: Text('Race',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(
                                label: Text('Health',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(
                                label: Text('Weight',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(
                                label: Text('Vaccinated',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(
                                label: Text('Update',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(
                                label: Text('Delete',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                            DataColumn(
                                label: Text('Profile',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromARGB(255, 0, 0, 0)))),
                          ],
                          rows: _filteredSheepList.map((sheep) {
                            return DataRow(
                              cells: [
                                DataCell(Text(sheep.necklaceID)),
                                DataCell(Text(sheep.age.toString())),
                                DataCell(Text(sheep.race)),
                                DataCell(Text(sheep.healthStatus)),
                                DataCell(Text(sheep.weight.toString())),
                                DataCell(Text(sheep.vaccinated ? 'Yes' : 'No')),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Color.fromARGB(255, 0, 255, 47),
                                    ),
                                    onPressed: () {
                                      _showUpdateSheepDialog(sheep);
                                    },
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Color.fromARGB(255, 255, 0, 0),
                                    ),
                                    onPressed: () {
                                      _deleteSheep(sheep.id);
                                    },
                                  ),
                                ),
                                DataCell(IconButton(
                                  icon: const Icon(
                                    Icons.align_vertical_bottom_sharp,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => SheepProfileScreen(
                                        idNecklace: sheep.necklaceID,
                                        sheep: sheep,
                                      ),
                                    ));
                                  },
                                )),
                              ],
                            );
                          }).toList(),
                        ),
                      )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.orange,
        shape: const CircleBorder(),
        onPressed: _showAddSheepDialog,
        tooltip: 'Add Sheep',
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
