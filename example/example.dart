import 'dart:async';

import 'package:algolia_sdk/algolia_sdk.dart';

void main() async {
  ///
  /// Initiate Algolia in your project
  ///
  Algolia algolia = Application.algolia;
  AlgoliaTask taskAdded,
      taskUpdated,
      taskDeleted,
      taskBatch,
      taskClearIndex,
      taskDeleteIndex;
  AlgoliaObjectSnapshot addedObject;

  ///
  /// 1. Perform Adding Object to existing Index.
  ///
  Map<String, dynamic> addData = {
    'name': 'John Smith',
    'contact': '+1 609 123456',
    'email': 'johan@example.com',
    'isDelete': false,
    'status': 'published',
    'createdAt': DateTime.now(),
    'modifiedAt': DateTime.now(),
  };
  taskAdded = await algolia.instance.index('contacts').addObject(addData);

  // Checking if has [AlgoliaTask]
  print(taskAdded.data);

  ///
  /// 2. Perform Get Object to existing Index.
  ///
  /// -- A Delay of 3 seconds is added for algolia to cdn the object for retrieval.
  addedObject = await Future.delayed(Duration(seconds: 3), () async {
    return await algolia.instance
        .index('contacts')
        .object(taskAdded.data['objectID'].toString())
        .getObject();
  });

  // Checking if has [AlgoliaObjectSnapshot]
  print('\n\n');
  print(addedObject.data);

  ///
  /// 3. Perform Updating Object to existing Index.
  ///
  Map<String, dynamic> updateData =
      Map<String, dynamic>.from(addedObject.data!);
  updateData['contact'] = '+1 609 567890';
  updateData['modifiedAt'] = DateTime.now();
  taskUpdated = await algolia.instance
      .index('contacts')
      .object(addedObject.objectID)
      .updateData(updateData);

  // Checking if has [AlgoliaTask]
  print('\n\n');
  print(taskUpdated.data);

  ///
  /// 4. Perform Delete Object to existing Index.
  ///
  taskDeleted = await algolia.instance
      .index('contacts')
      .object(addedObject.objectID)
      .deleteObject();

  // Checking if has [AlgoliaTask]
  print('\n\n');
  print(taskDeleted.data);

  ///
  /// 5. Perform Batch
  ///
  AlgoliaBatch batch = algolia.instance.index('contacts').batch();
  batch.clearIndex();
  for (int i = 0; i < 10; i++) {
    Map<String, dynamic> addData = {
      'name': 'John ${DateTime.now().microsecond}',
      'contact': '+1 ${DateTime.now().microsecondsSinceEpoch}',
      'email': 'johan.${DateTime.now().microsecond}@example.com',
      'isDelete': false,
      'status': 'published',
      'createdAt': DateTime.now(),
      'modifiedAt': DateTime.now(),
    };
    batch.addObject(addData);
  }

  // Get Result/Objects
  taskBatch = await batch.commit();

  // Checking if has [AlgoliaTask]
  print('\n\n');
  print(taskBatch.data);

  ///
  /// 6. Perform Query
  ///
  AlgoliaQuery query = algolia.instance.index('contacts').search('john');

  // Perform multiple facetFilters
  query = query.setFacetFilter('status:published');
  query = query.setFacetFilter('isDelete:false');

  // Get Result/Objects
  AlgoliaQuerySnapshot snap = await query.getObjects();

  // Checking if has [AlgoliaQuerySnapshot]
  print('\n\n');
  print('Hits count: ${snap.nbHits}');

  ///
  /// 7. Perform List all Indices
  ///
  AlgoliaIndexesSnapshot indices = await algolia.instance.getIndices();

  // Checking if has [AlgoliaIndexesSnapshot]
  print('\n\n');
  print('Indices count: ${indices.items.length}');

  ///
  /// 8. Perform Clear Index.
  ///
  taskClearIndex = await algolia.instance.index('contacts').clearIndex();

  // Checking if has [AlgoliaTask]
  print('\n\n');
  print(taskClearIndex.data);

  ///
  /// 9. Perform Delete Index.
  ///
  taskDeleteIndex = await algolia.instance.index('contact').deleteIndex();
  print(taskDeleteIndex.data);

  ///
  /// 10. Get Index Setting Instance.
  ///
  AlgoliaIndexSettings settingsRef = algolia.instance.index('contact').settings;

  // Get Settings
  Map<String, dynamic>? currentSettings = await settingsRef.getSettings();

  // Checking if has [Map]
  print('\n\n');
  print(currentSettings);

  // Set Settings
  AlgoliaSettings settingsData = settingsRef;
  settingsData =
      settingsData.setReplicas(const ['index_copy_1', 'index_copy_2']);
  AlgoliaTask setSettings = await settingsData.setSettings();

  // Checking if has [AlgoliaTask]
  print('\n\n');
  print(setSettings.data);
}

class Application {
  static Algolia algolia = Algolia.init(
    applicationId: 'YOUR_APPLICATION_ID',
    apiKey: 'YOUR_API_KEY',
  );
}
