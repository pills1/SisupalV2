import 'package:cloud_firestore/cloud_firestore.dart';

class DataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- 1. UPLOAD SINHALA (Fixed ID: 'sinhala_grade5_01') ---
  Future<void> uploadSinhalaPart2Data() async {
    // We define a SPECIFIC ID so it never duplicates
    String lessonId = 'sinhala_grade5_01';

    DocumentReference lessonRef = _db.collection('lessons').doc(lessonId);

    // Use .set() instead of .add() to overwrite if it exists
    await lessonRef.set({
      'subject': 'Sinhala',
      'topic': 'Sinhala Language Practice 01',
      'description': 'Reading comprehension, grammar, and correct usage.',
      'content': """
    අපේ පාසලේ ගුරුවරුන්, සිසුන්, දෙමාපියන් සහ ආදී ශිෂ්‍යන්ගේ සහභාගිත්වයෙන් පසුගිය දා ශ්‍රමදානයක් පවත්වන ලදී. 
    ශ්‍රමදානය පැවැත්වීමේ මූලික අරමුණ වූයේ පාසල් වත්ත පිරිසිදු කිරීමයි. මල් පාත්ති සකස් කිරීම, පාසල් වත්තේ දිරන සහ නොදිරන ද්‍රව්‍ය තෝරා වෙන් කිරීම, කුණු කසල බැහැර කිරීම වැනි කටයුතු එහිදී සිදු කරන ලදී. 
    ලොකු කුඩා සෑම කෙනෙක් ම ඒ සඳහා සහභාගි වූයේ ඉමහත් ප්‍රීතියකිනි. විදුහල්පතිතුමා විසින් සහභාගි වූ සැමට ස්තූතිය පළ කරමින් වැඩසටහන නිමා කරන ලදී. 
    මගේ පාසල දැන් කෙතරම් ලස්සන ද කියා මට සිතුනි.
    """,
      'order': 1,
      'grade': 5, // Explicitly set grade
    });

    // Sub-collection: Questions (We delete old ones first to be safe)
    var oldQuestions = await lessonRef.collection('questions').get();
    for (var doc in oldQuestions.docs) {
      await doc.reference.delete();
    }

    // Add Questions
    List<Map<String, dynamic>> questions = [
      {
        'qID': 1,
        'question': 'ශ්‍රමදානයට සහභාගී වූයේ කවුරුන් ද?',
        'options': ['ගුරුවරුන් සහ සිසුන් පමණි', 'සිසුන් සහ දෙමාපියන් පමණි', 'අපේ පාසලේ ගුරුවරුන්, සිසුන්, දෙමාපියන් සහ ආදී ශිෂ්‍යයන්', 'විදුහල්පතිතුමා පමණි'],
        'correctIndex': 2,
      },
      {
        'qID': 2,
        'question': 'ශ්‍රමදානය පැවැත්වීමේ මූලික අරමුණ කුමක් ද?',
        'options': ['ක්‍රීඩා පිටිය සකස් කිරීම', 'පාසල් වත්ත පිරිසිදු කිරීම', 'ගස් සිටුවීම', 'ගොඩනැගිලි අලුත්වැඩියා කිරීම'],
        'correctIndex': 1,
      },
      {
        'qID': 3,
        'question': 'ශ්‍රමදානයේ දී සිදු කරන ලද ක්‍රියාකාරකමක් තෝරන්න.',
        'options': ['පන්ති කාමර පිරිසිදු කිරීම', 'තාප්ප බැඳීම', 'මල් පාත්ති සකස් කිරීම', 'ගස් කැපීම'],
        'correctIndex': 2,
      },
      // --- Q4 ---
      {
        'qID': 4,
        'question': '\'ඉවත් කිරීම\' යන්නට සමාන අර්ථයක් දැක්වෙන ලෙස ඡේදයේ යොදා ඇත්තේ කුමක් ද?',
        'options': [
          'සකස් කිරීම',
          'තෝරා වෙන් කිරීම',
          'බැහැර කිරීම',
          'නිමා කිරීම'
        ],
        'correctIndex': 2,
      },
      // --- Q5 ---
      {
        'qID': 5,
        'question': 'ඡේදයේ සඳහන් විශේෂණ පදයක් තෝරන්න.',
        'options': [
          'කුණු කසළ',
          'ඉමහත්',
          'වත්ත',
          'ශ්‍රමදානය'
        ],
        'correctIndex': 1,
      },
      // --- Q6 ---
      {
        'qID': 6,
        'question': 'පාසල පිළිබඳ ව ශිෂ්‍යයාට සිතුණේ කුමක් ද?',
        'options': [
          'පාසල දැන් කෙතරම් ලස්සන ද කියා',
          'ශ්‍රමදානය හරිම මහන්සියි කියා',
          'නැවත ශ්‍රමදානයක් ඕනෑ කියා',
          'ගෙදර යන්න ඕනේ කියා'
        ],
        'correctIndex': 0,
      },
      // --- Q7 ---
      {
        'qID': 7,
        'question': 'වැරදි අක්ෂර නිවැරදි කර ඇති වාක්‍යය තෝරන්න:\n"රූපවාහිනිය අකණ්ඩ ව දීර්ඝ කාලයක් නැරඹීමෙන් රෝගාබාදවලට ගොදුරු විය හැකි ය."',
        'options': [
          'රූපවාහිනිය අකණ්ඩ ව දීර්ග කාලයක් නැරඹීමෙන් රෝගාබාධවලට ගොදුරු විය හැකි ය.',
          'රූපවාහිනිය අඛණ්ඩ ව දීර්ඝ කාලයක් නැරඹීමෙන් රෝගාබාධවලට ගොදුරු විය හැකි ය.',
          'රූපවාහිනිය අකණ්ඩ ව දීර්ඝ කාලයක් නැරඹීමෙන් රෝගාබාධවලට ගොදුරු විය හැකි ය.',
          'රූපවාහිනිය අඛණ්ඩ ව දීර්ඝ කාලයක් නැරඹීමෙන් රෝගාබාදවලට ගොදුරු විය හැකි ය.'
        ],
        'correctIndex': 1,
      },
      // --- Q8 ---
      {
        'qID': 8,
        'question': '(i) "ගිරවා අඹ ගස උඩ සිටියා" - මෙය ලිඛිත බසින් ලියූ විට:',
        'options': [
          'ගිරවා අඹ ගස උඩ සිටියෝ ය.',
          'ගිරවා අඹ ගස උඩ සිටියි සිටින්නේ ය.',
          'ගිරවා අඹ ගස උඩ උන්නේ ය.',
          'ගිරවා අඹ ගස උඩ ඉඳියි.'
        ],
        'correctIndex': 1,
      },
      // --- Q9 ---
      {
        'qID': 9,
        'question': '(ii) "මම මල් වත්තට ගිහින් මල් කැඩුවා" - මෙය ලිඛිත බසින් ලියූ විට:',
        'options': [
          'මම මල් වත්තට ගොස් මල් කැඩුවෙමි.',
          'මම මල් වත්තට ගොස් මල් කැඩුවා ය.',
          'මම මල් වත්තට ගිහින් මල් කැඩුවෙමි.',
          'මම මල් වත්තට ගොස් මල් කඩමි.'
        ],
        'correctIndex': 3,
      },
      // --- Q10 ---
      {
        'qID': 10,
        'question': '(i) පද ගළපා අර්ථවත් වාක්‍යයක් සාදන්න:\nකළෙමි / ගොනු / අවශ්‍ය / කරුණු / මූලික / රචනාවට',
        'options': [
          'රචනාවට මූලික කරුණු අවශ්‍ය ගොනු කළෙමි.',
          'අවශ්‍ය මූලික කරුණු රචනාවට ගොනු කළෙමි.',
          'රචනාවට අවශ්‍ය මූලික කරුණු ගොනු කළෙමි.',
          'ගොනු කළෙමි රචනාවට අවශ්‍ය මූලික කරුණු.'
        ],
        'correctIndex': 2,
      },
      // --- Q11 ---
      {
        'qID': 11,
        'question': '(ii) පද ගළපා අර්ථවත් වාක්‍යයක් සාදන්න:\nලක්ෂණ / විය / ඩෙංගු / සැලකිලිමත් / යුතු ය / රෝග / පිළිබඳ ව',
        'options': [
          'ඩෙංගු රෝග ලක්ෂණ පිළිබඳ ව සැලකිලිමත් විය යුතු ය.',
          'ලක්ෂණ පිළිබඳ ව ඩෙංගු රෝග සැලකිලිමත් විය යුතු ය.',
          'සැලකිලිමත් විය යුතු ය ඩෙංගු රෝග ලක්ෂණ පිළිබඳ ව.',
          'ඩෙංගු රෝග පිළිබඳ ව ලක්ෂණ සැලකිලිමත් විය යුතු ය.'
        ],
        'correctIndex': 0,
      },
      // --- Q12 ---
      {
        'qID': 12,
        'question': 'නිවැරදි විරාම ලකුණු යොදා ඇති වාක්‍යය තෝරන්න:\n"ගුරුවරිය අපේ ලංකාව ගීතය ගායනා කළා ය"',
        'options': [
          'ගුරුවරිය, "අපේ ලංකාව" ගීතය ගායනා කළා ය.',
          'ගුරුවරිය "අපේ ලංකාව" ගීතය ගායනා කළා ය.',
          'ගුරුවරිය අපේ ලංකාව "ගීතය" ගායනා කළා ය.',
          'ගුරුවරිය, අපේ ලංකාව ගීතය, ගායනා කළා ය.'
        ],
        'correctIndex': 1,
      },
      // --- Q13 ---
      {
        'qID': 13,
        'question': '(i) "එක හුස්මට" යන්නෙහි අදහස කුමක්ද?',
        'options': [
          'දැඩි සතුටක දී කියයි',
          'සම්පූර්ණයෙන් කියවා අවසන් වූ විට කියයි',
          'නොසිතූ විටක බේරුණු විට දී කියයි',
          'ඉතා ඉක්මනින් යමක් කියවා අවසන් වූ විට කියයි'
        ],
        'correctIndex': 3,
      },
      // --- Q14 ---
      {
        'qID': 14,
        'question': '(ii) "අකුරක් නෑර" යන්නෙහි අදහස කුමක්ද?',
        'options': [
          'සම්පූර්ණයෙන් කියවා අවසන් වූ විට කියයි',
          'ඉතා ඉක්මනින් යමක් කියවා අවසන් වූ විට කියයි',
          'දැඩි සතුටක දී කියයි',
          'කෙටියෙන් කියන විට කියයි'
        ],
        'correctIndex': 0,
      },
      // --- Q15 ---
      {
        'qID': 15,
        'question': '(i) "පරවියා ඉගිලී ගියෝ ය." - මෙම වාක්‍යය නිවැරදි ද?',
        'options': [
          'නිවැරදියි (✓)',
          'වැරදියි (X)'
        ],
        'correctIndex': 1,
      },
      // --- Q16 ---
      {
        'qID': 16,
        'question': '(ii) "ගුරුතුමා ලස්සන කතන්දරයක් කිවුවේ ය." - මෙම වාක්‍යය නිවැරදි ද?',
        'options': [
          'නිවැරදියි (✓)',
          'වැරදියි (X)'
        ],
        'correctIndex': 0,
      },
      // --- Q17 ---
      {
        'qID': 17,
        'question': '(iii) "මලිති සහ දිනිති දිනපතා පුවත්පත් කියවති." - මෙම වාක්‍යය නිවැරදි ද?',
        'options': [
          'නිවැරදියි (✓)',
          'වැරදියි (X)'
        ],
        'correctIndex': 0,
      },
      // --- Q18 ---
      {
        'qID': 18,
        'question': 'තීරණ ගැනීමේ දී බුද්ධිමත් ලෙස කටයුතු නොකර නුසුදුසු තීරණ ගැනීම (නරක දෙයක් වෙනුවට ඊටත් වඩා නරක දෙයක් තෝරා ගැනීම):',
        'options': [
          'අනුන්ට කළ දේ තමන්ට පල දේ',
          'කැකිල්ලේ රජ්ජුරුවගේ නඩු තීන්දුව වගේ.',
          'කලබල වූ විට අම්බලම කණක් යයිද',
          'කටුස්සාගේ කරේ රත්තරන් බැන්දා වගේ'
        ],
        'correctIndex': 1,
      },
      // --- Q19 ---
      {
        'qID': 19,
        'question': '(i) පුංචි ළමයි ........................................ ලබා ගැනීමට බොහෝ කැමැත්තක් දක්වයි.',
        'options': [
          'වතු පිටි',
          'ඉඩ කඩම්',
          'තෑගි බෝග',
          'ගමන් බිමන්'
        ],
        'correctIndex': 2,
      },
      // --- Q20 ---
      {
        'qID': 20,
        'question': '(ii) අප සැවොම ........................................ අය සමග සහයෝගයෙන් ජීවත් විය යුතු ය.',
        'options': [
          'වතු පිටි',
          'අහල පහළ',
          'තෑගි බෝග',
          'ගමන් බිමන්'
        ],
        'correctIndex': 1,
      },
      // --- Q21 ---
      {
        'qID': 21,
        'question': '"අම්මා උදෑසනින් ම රැකියාවට ගියා ය." - මෙම වාක්‍යය පුරුෂ ලිංගයට හරවා ලියූ විට:',
        'options': [
          'තාත්තා උදෑසනින් ම රැකියාවට ගියා ය.',
          'තාත්තා උදෑසනින් ම රැකියාවට ගියේ ය.',
          'තාත්තා උදෑසනින් ම රැකියාවට ගියෝ ය.',
          'අයියා උදෑසනින් ම රැකියාවට ගියා ය.'
        ],
        'correctIndex': 1,
      },
    ];

    for (var q in questions) {
      await lessonRef.collection('questions').add(q);
    }
    print("✅ Sinhala Data Updated (Fixed ID)");
  }

  // --- 2. UPLOAD MATH (Fixed ID: 'math_grade5_01') ---
  Future<void> uploadMathematicsData() async {
    String lessonId = 'math_grade5_01';
    DocumentReference lessonRef = _db.collection('lessons').doc(lessonId);

    await lessonRef.set({
      'subject': 'Mathematics',
      'topic': 'Mathematics Practice 01',
      'description': 'Mathematical problems from 2021 Exam Part II.',
      'content': "ගණිත ගැටළු විසඳීම සඳහා කටු වැඩ කොළයක් භාවිතා කරන්න. (Use a rough paper).",
      'order': 1,
      'grade': 5,
    });

    var oldQuestions = await lessonRef.collection('questions').get();
    for (var doc in oldQuestions.docs) { await doc.reference.delete(); }

    List<Map<String, dynamic>> questions = [
      {
        'qID': 1,
        'question': "'හය දහස් තිස් හත' සංඛ්‍යාව ඉලක්කමෙන් ලියන්න.",
        'options': ['6307', '6037', '6370', '60037'],
        'correctIndex': 1,
      },
      {
        'qID': 2,
        'question': '8415 සංඛ්‍යාව ස්ථානීය අගය අනුව විහිදුවා ලියූ විට නිවැරදි පිළිතුර කුමක්ද?',
        'options': ['8000 + 400 + 10 + 5', '8000 + 40 + 10 + 5', '800 + 400 + 10 + 5', '8000 + 400 + 15'],
        'correctIndex': 0,
      },
      // Q3
      {
        'qID': 3,
        'question': 'සංඛ්‍යා රටාවේ හිස්තැන්වලට ආ යුතු සංඛ්‍යා යුගලය තෝරන්න:\n....... , ....... , 11 , 14 , 17 , 20',
        'options': ['9, 10', '8, 10', '5, 8', '6, 9'],
        'correctIndex': 2,
      },
      // Q4
      {
        'qID': 4,
        'question': '7, 5, 4 යන ඉලක්කම් ඇසුරෙන් ලිවිය හැකි විශාල ම සංඛ්‍යාව සහ කුඩා ම සංඛ්‍යාව අතර වෙනස කීය ද?',
        'options': ['297', '300', '198', '250'],
        'correctIndex': 0,
      },
      // Q5
      {
        'qID': 5,
        'question': 'ජනවාරි මාසයේ නිපද වූ මුළු බීම බෝතල් සංඛ්‍යාව කීය ද?\n(අඹ: 1537, දොඩම්: 1325)',
        'options': ['2852', '2862', '2900', '2762'],
        'correctIndex': 1,
      },
      // Q6
      {
        'qID': 6,
        'question': 'ජනවාරි සහ පෙබරවාරි මාසවල නිපදවන ලද අඹ බීම බෝතල් සංඛ්‍යා අතර වෙනස කීය ද?\n(ජනවාරි: 1537, පෙබරවාරි: 1065)',
        'options': ['472', '532', '450', '572'],
        'correctIndex': 0,
      },
      // Q7
      {
        'qID': 7,
        'question': '107, 5 න් ගුණ කළ විට ලැබෙන පිළිතුර කුමක් ද?',
        'options': ['5035', '535', '507', '570'],
        'correctIndex': 1,
      },
      // Q8
      {
        'qID': 8,
        'question': 'භාජනයකට අල්ලන උපරිම ජල ප්‍රමාණය ලීටර් 2 කි. එහි මිලිලීටර් 750 ක් ඇත. එය සම්පූර්ණයෙන් පිරවීමට තව කොපමණ අවශ්‍ය ද?',
        'options': [
          '1 l 500 ml',
          '1 l 250 ml',
          '250 ml',
          '1 l 750 ml'
        ],
        'correctIndex': 1,
      },
      // Q9 (Image: Mangoes)
      {
        'qID': 9,
        'question': 'රූපයේ ඇති අඹ ගෙඩි ගොඩෙන් හතරෙන් පංගු තුනක් (3/4) යනු අඹ ගෙඩි කීය ද?',
        'options': ['9', '12', '8', '16'],
        'correctIndex': 1,
        'imagePath': 'assets/images/math_q9.png', // Make sure this file exists!
      },
      // Q10
      {
        'qID': 10,
        'question': 'පොත් 424 ක් පෙට්ටි 4 කට සමාන ව අසුරන ලදී. එක් පෙට්ටියකට අසුරන ලද පොත් සංඛ්‍යාව කීය ද?',
        'options': ['106', '16', '160', '116'],
        'correctIndex': 0,
      },
      // Q11
      {
        'qID': 11,
        'question': 'රු.125 ක අන්නාසි ගෙඩියක් සහ රු.80 ක කොමඩු ගෙඩි දෙකක් මිල දී ගෙන රු.500 නෝට්ටුවක් දුන් විට ඉතිරි මුදල කීයද?',
        'options': ['රු. 215', 'රු. 295', 'රු. 205', 'රු. 315'],
        'correctIndex': 0,
      },
      // Q12
      {
        'qID': 12,
        'question': 'මීටර් 5 ක් දිග රෙද්දකින් මීටර් 2 සෙන්ටිමීටර් 25 ක් කපා ඉවත් කළේ නම් ඉතිරි රෙදි ප්‍රමාණය කොපමණ ද?',
        'options': [
          '3 m 75 cm',
          '2 m 75 cm',
          '2 m 25 cm',
          '3 m 25 cm'
        ],
        'correctIndex': 1,
      },
      // Q13 (Image: Clock)
      {
        'qID': 13,
        'question': 'එක් තැටියක: අන්නාසි + 50g. අනෙක් තැටියක: 1kg + 500g. අන්නාසි ගෙඩියේ බර කොපමණ ද?',
        'options': [
          '1 kg 550 g',
          '1 kg 450 g',
          '1 kg 50 g',
          '950 g'
        ],
        'correctIndex': 1,
      },
      {
        'qID': 14,
        'question': 'ඔරලෝසු මුහුණතේ දැක්වෙන වේලාව (පස්වරු) තෝරන්න.',
        'options': [
          '12:03',
          '12:15',
          '3:00',
          '3:12'
        ],
        'correctIndex': 1,
        'imagePath': 'assets/images/math_q13.png',
      },
      // Q15 (Image: Graph)
      {
        'qID': 15,
        'question': 'ප්‍රස්තාරය අනුව සිසුන් සමාන සංඛ්‍යාවක් කැමති පලතුරු වර්ග මොනවා ද?',
        'options': [
          'අඹ සහ පේර',
          'අන්නාසි සහ දෙළුම්',
          'ගස්ලබු සහ දෙළුම්',
          'අඹ සහ අන්නාසි'
        ],
        'correctIndex': 1,
        'imagePath': 'assets/images/math_q14.png',
      },
      // Q16 (Image: Graph Part 2)
      {
        'qID': 16,
        'question': 'ප්‍රස්තාරය අනුව, ගස්ලබුවලට කැමති සිසුන් සංඛ්‍යාවට වඩා අඹවලට කැමති සිසුන් සංඛ්‍යාව කීය ද?',
        'options': ['3', '4', '5', '2'],
        'correctIndex': 1,
        'imagePath': 'assets/images/math_q14.png', // Same image as above
      },
    ];

    for (var q in questions) {
      await lessonRef.collection('questions').add(q);
    }
    print("✅ Math Data Updated (Fixed ID)");
  }

  // --- 3. UPLOAD ENVIRONMENT (Fixed ID: 'env_grade5_01') ---
  Future<void> uploadEnvironmentData() async {
    String lessonId = 'env_grade5_01';
    DocumentReference lessonRef = _db.collection('lessons').doc(lessonId);

    await lessonRef.set({
      'subject': 'Environment',
      'topic': 'Environment Practice 01',
      'description': 'Questions from 2021 Past Paper.',
      'content': "පරිසරය විෂය සඳහා රූප සටහන් හොඳින් නිරීක්ෂණය කරන්න.",
      'order': 1,
      'grade': 5,
    });

    var oldQuestions = await lessonRef.collection('questions').get();
    for (var doc in oldQuestions.docs) { await doc.reference.delete(); }

    List<Map<String, dynamic>> questions = [
      {
        'qID': 1,
        'question': 'කොළ කැඳ සකස් කිරීමට යොදා ගන්නේ මින් කුමක් ද?',
        'options': ['බෙලිමල්', 'හාතාවාරිය', 'කතුරුමුරුංගා'],
        'correctIndex': 1,
      },
      // Q2 (Old 31)
      {
        'qID': 2,
        'question': 'එක් බීජයක් පමණක් ඇති පලතුර කුමක් ද?',
        'options': ['පේර', 'රඹුටන්', 'ගස්ලබු'],
        'correctIndex': 1,
      },
      // Q3 (Old 32)
      {
        'qID': 3,
        'question': 'එදිනෙදා භාවිතයට අවශ්‍ය ලෝහ උපකරණ සාදන කර්මාන්තය කුමක්ද?',
        'options': ['වඩු කර්මාන්තය', 'පෙදරේරු කර්මාන්තය', 'කම්මල් කර්මාන්තය'],
        'correctIndex': 2,
      },
      // Q4 (Old 33)
      {
        'qID': 4,
        'question': 'උණුසුම් පානයක් පිළිගැන්වීම සඳහා වඩාත් ම සුදුසු භාජනය කුමක්ද?',
        'options': [
          'අඬුව රහිත ප්ලාස්ටික් කෝප්පයක්',
          'අඬුව සහිත පිරිසි කෝප්පයක්',
          'විනිවිද පෙනෙන වීදුරුවක්'
        ],
        'correctIndex': 1, // Handle prevents burning fingers
      },
      // Q5 (Old 34)
      {
        'qID': 5,
        'question': 'ජාතික කොඩියේ රතු පැහැති පසුබිමෙන් සංකේතවත් කරන්නේ,',
        'options': [
          'විවිධ ජාතීන් නියෝජනයයි',
          'ජාතීන් අතර එකමුතුවයි',
          'ජාතික අභිමානයයි'
        ],
        'correctIndex': 2,
      },
      // Q6 (Old 35)
      {
        'qID': 6,
        'question': 'චිත්‍රයක් වර්ණ ගැන්වීමට අවශ්‍ය දම් වර්ණය සාදා ගැනීම සඳහා සමාන ප්‍රමාණවලින් මිශ්‍ර කළ යුතුවර්ණ දෙක මොනවාද?',
        'options': ['නිල් සහ කහ', 'නිල් සහ රතු', 'කහ සහ රතු'],
        'correctIndex': 1,
      },
      // Q7 (Old 36)
      {
        'qID': 7,
        'question': 'පාද රහිත සත්ත්වයකු වන්නේ,',
        'options': ['පත්තෑයා ය', 'ගැඩවිලා ය', 'කැරපොත්තා ය'],
        'correctIndex': 1, // Earthworm has no legs
      },
      // Q8 (Old 37)
      {
        'qID': 8,
        'question': 'කමල්ගේ දවල් ආහාරය සඳහා සිවුණු බත්, අර්තාපල්, බණ්ඩක්කා සහ මුකුණුවැන්න මැල්ලුම ආහාරකාණ්ඩ දෙකකට අයත් වේ. ඒවාට අමතරව මෙම ආහාර වේලට ඇතුළත් විය යුතු අනෙක් ආහාරකාණ්ඩය කුමක්ද?',
        'options': ['ශක්තිජනක', 'ආරක්ෂක', 'වර්ධක'],
        'correctIndex': 2, // Needs Protein (Growth)
      },
      // Q9 (Old 38)
      {
        'qID': 9,
        'question': '"උණ දඬු කපන තැන උණ දඬු රිකිල්ලා - බට දඬු කපන තැන බට දඬු රිකිල්ලා',
        'options': ['පතල් කවියකි', 'පැල් කවියකි', 'පාරු කවියකි'],
        'correctIndex': 1,
      },
      // Q10 (Old 39) - IMAGE
      {
        'qID': 10,
        'question': 'ඉහත බදුන් තුනට නිරෝගී මෑ බීජ සමාන ප්‍රමාණවලින් දමා ඇත. බීජ පැළවීම සඳහා කුමන සාධකයක්අවශ්‍ය දැයි සෙවීමට මෙම පරීක්ෂණය යොදාගන්නේ ද?',
        'options': ['ආලෝකය', 'වාතය', 'තෙතමනය'],
        'correctIndex': 1, // Air (Oil layer blocks air)
        'imagePath': 'assets/images/env_q10.png'
      },
      // Q11 (Old 40)
      {
        'qID': 11,
        'question': 'දෛනික ව කාලසටහනකට අනුව වැඩ කිරීම නිසා,',
        'options': [
          'නියමිත කාලයක් තුළ දී කාර්යයක් ඉටු කිරීමට පුරුදු වේ',
          'එදිනෙදා සිදුකළ යුතු කාර්යයන් අතපසු වේ',
          'සෙල්ලම් කිරීමට කාලය නොමැති වේ'
        ],
        'correctIndex': 0,
      },
      // Q12 (Old 41)
      {
        'qID': 12,
        'question': 'සිසුවකු පොතක ලියා තිබූ වගුවක් ඉහත දක්වා ඇත. කල් ඉකුත් වීමේ දිනය වැරදියට ලියා ඇත්තේකුමන ආහාරයේ ද?',
        'options': ['ටින් කළ මාළු', 'මුදවපු කිරි', 'ටින් කළ උකු කිරි'],
        'correctIndex': 1, // Curd expires fast, not in 1 year
        'imagePath': 'assets/images/env_q12.png'
      },
      // Q13 (Old 42)
      {
        'qID': 13,
        'question': 'කාල නියමයක් නොමැතිව මල් පිපෙන ශාකයක් සහ වසරේ එක් කාලයකට පමණක් මල් පිපෙන ශාකයක් පිළිවෙළින් සඳහන් පිළිතුර කුමක්ද?',
        'options': ['පොල්, කෙසෙල්', 'රඹුටන්, එරබදු', 'කෙසෙල්, එරබදු'],
        'correctIndex': 2, // Banana (Anytime) - Erabadu (Seasonal)
      },
      // Q14 (Old 43)
      {
        'qID': 14,
        'question': 'තඹ කම්බියක් පහත සඳහන් කුමක් වටා එතීමෙන් විද්‍යුත් චුම්භකයක් සාදාගත හැකි ද?',
        'options': ['යකඩ ඇණයක්', 'ලී පතුරක්', 'ප්ලාස්ටික් බටයක්'],
        'correctIndex': 0,
      },
      // Q15 (Old 44) - IMAGE
      {
        'qID': 15,
        'question': 'වියළි කෝෂයකට විදුලි පන්දම් බල්බ දෙකක් වයර් කැබලි මගින් සම්බන්ධ කර ඇති අවස්ථා කුනක් පහත දැක්වේ. ඒ අතුරෙන් එක් බල්බයක් පමණක් දැල්වෙන අවස්ථාව කුමක් ද?',
        'options': ['(1)', '(2)', '(3)'],
        'correctIndex': 2, // Short circuit bypasses one bulb
        'imagePath': 'assets/images/env_q15.png'
      },
      // Q16 (Old 45)
      {
        'qID': 16,
        'question': 'සමනලයාගේ ජීවන චක්‍රය නිරීක්ෂණය සඳහා සමනල බිත්තර සහිත කුඩා කතුරුමුරුංගා අතු කැබැල්ලක්වීදුරු බෝතලයකට දමා ඇත. එහි කට කඩදාසියකින් වසා නූලකින් බැඳ අල්පෙනෙත්තකින් කඩදාසිය සිදුරු කරන ලදී. එසේ සිදුරු කරන්නේ,',
        'options': ['ජලය ඇතුළුවීමටයි', 'වාතය ඇතුළු වීමටයි', 'ආලෝකය ඇතුළුවීමටයි'],
        'correctIndex': 1,
      },
      // Q17 (Old 46)
      {
        'qID': 17,
        'question': 'හොදින් ආලෝකය ඇති අවස්ථාවක සිදුරු කැමරාවක් භාවිත කරමින් ගසක් දෙස බැලූ විට එම ගසපෙනෙන්නේ,',
        'options': ['උඩුකුරුව ය', 'යටිකුරුව ය', 'පවතින ප්‍රමාණයට ම ය'],
        'correctIndex': 1, // Inverted (Yatikuru)
      },
      // Q18 (Old 47)
      {
        'qID': 18,
        'question': 'සාමූහිකව කටයුතු කිරීමෙන් ජය ලබාගත හැකි බව දැක්වෙන්නේ,',
        'options': ['කපුටා සහ කේජු කෑල්ලේ කථාවෙනි', 'තොප්පි වෙළෙන්දාගේ කථාවෙනි', 'වටු කුරුල්ලන්ගේ කථාවෙනි'],
        'correctIndex': 2,
      },
      // Q19 (Old 48)
      {
        'qID': 19,
        'question': 'බල්ලකු සපා කෑ විට පළමුවෙන් ම කළ යුතු වන්නේ කුමක් ද?',
        'options': [
          'සපා කෑ ස්ථානය සබන් යොදා ගලා යන පිරිසිදු ජලයෙන් හොඳින් සේදීම',
          'සපා කෑ ස්ථානයට ඉහළින් රෙදි පටි වලින් තදින් ගැට ගැසීම',
          'සපා කෑ ස්ථානයේ අත් බෙහෙතක් තබා හොඳින් බැඳීම'
        ],
        'correctIndex': 0,
      },
      // Q20 (Old 49)
      {
        'qID': 20,
        'question': 'වෙළදසලක අලෙවිය සඳහා ඇති බීම වර්ගයක ලේබලයෙහි රතු වර්ණ රවුමක් යොදා ඇත. එයින්අදහස් වන්නේ.',
        'options': [
          'සීනි සම්පූර්ණයෙන් ම ඉවත් කර ඇති බවයි',
          'සීනි අඩු ප්‍රමාණයකින් ඇති බවයි',
          'අධික ලෙස සීනි ඇති බවයි'
        ],
        'correctIndex': 2, // Red = High Sugar
      },
      // Q21 (Old 50) - IMAGE
      {
        'qID': 21,
        'question': ' සමාන බරක් ඇදගෙන යාම දැක්වෙන පහත අවස්ථා තුනෙන් බර ඇදගෙන යාමට වඩාත් අපහසු අවස්ථාව කුමක් ද?',
        'options': ['(1)', '(2)', '(3)'],
        'correctIndex': 0, // Rough surface (1) is hardest
        'imagePath': 'assets/images/env_q21.png'
      },
      // Q22 (Old 51)
      {
        'qID': 22,
        'question': 'භාණ්ඩ පිළිබඳ වෙළඳ දැන්වීම්වල මූලික අරමුණ වී ඇත්තේ,',
        'options': [
          'එම භාණ්ඩ මිල දී ගැනීම සඳහා මිනිසුන් වැඩි වශයෙන් යොමු කිරීමයි.',
          'ග එම භාණ්ඩවල ගුණ අගුණ පිළිබඳ ව මිනිසුන් දැනුවත් කිරීමයි',
          'එම භාණ්ඩ නිෂ්පාදනය සඳහා වෙනත් අය දිරිගැන්වීමයි'
        ],
        'correctIndex': 0,
      },
      // Q23 (Old 52)
      {
        'qID': 23,
        'question': 'ඓතිහාසික වැදගත්කමක් ඇති ස්ථාන නැරඹීමේ දී නොකළ යුතු ක්‍රියාව කුමක් ද?',
        'options': [
          'මතකයේ රඳවා ගැනීම සඳහා යම් යම් කොටස් රැගෙන යාමයි',
          'එහි ප්‍රදර්ශනය කර ඇති උපදෙස් අනුගමනය කිරීමයි',
          'එහි වැදගත්කම පිළිබඳ තොරතුරු විමසා දැනගැනීමයි'
        ],
        'correctIndex': 0,
      },
      // Q24 (Old 53) - IMAGE
      {
        'qID': 24,
        'question': 'A, B, C යනු ප්‍රමාණයෙන් සමාන වීදුරු තුනකි. එක ම ස්ථානයක ඇති ඉහත වීදුරු තුනට එක ම අවස්ථාවේ දී එක ම ප්‍රමාණයේ අයිස් කැට සමාන සංඛ්‍යාවක් දමන ලදී. අයිස් කැට ඉක්මනින් ම දියවෙන වීදුරුවේ සිට සෙමෙන් ම දියවෙන වීදුරුව තෙක් පිළිවෙළින් දැක්වෙන පිළිතුර කුමක් ද?',
        'options': ['A, B, C', 'B, C, A', 'C, A, B'],
        'correctIndex': 1, // Hot(B) > Cold Water(C) > Air(A)
        'imagePath': 'assets/images/env_q24.png'
      },
    ];

    for (var q in questions) {
      await lessonRef.collection('questions').add(q);
    }
    print("✅ Environment Data Updated (Fixed ID)");
  }

  // --- 4. UPLOAD ENGLISH & TAMIL (Fixed IDs) ---
  Future<void> uploadEnglishTamilData() async {
    // English Lesson
    DocumentReference engRef = _db.collection('lessons').doc('english_grade5_01');
    await engRef.set({
      'subject': 'English',
      'topic': 'English Practice 01',
      'description': 'Vocabulary and Sentence Building.',
      'content': "Read the questions carefully.",
      'order': 1,
      'grade': 5,
    });

    // Clear old English questions
    var oldEngQ = await engRef.collection('questions').get();
    for (var doc in oldEngQ.docs) { await doc.reference.delete(); }

    List<Map<String, dynamic>> engQuestions = [
      {'qID': 1, 'question': 'What is the Sinhala meaning of "Vegetables"?', 'options': ['පලතුරු', 'එළවළු', 'මල්'], 'correctIndex': 1},
      {'qID': 2, 'question': 'What is the Sinhala meaning of "Library"?', 'options': ['පාසල', 'පුස්තකාලය', 'රෝහල'], 'correctIndex': 1},
      {'qID': 3, 'question': 'Fill in the missing letters: F _ _ t', 'options': ['Frut', 'Fruit', 'Foot'], 'correctIndex': 1, 'imagePath': 'assets/images/eng_q3.png'},
      {'qID': 4, 'question': 'Fill in the missing letters: B _ _ _ _ _ f _ _', 'options': ['Buterfly', 'Butterfly', 'Buttefly'], 'correctIndex': 1, 'imagePath': 'assets/images/eng_q4.png'},
      {'qID': 5, 'question': 'Reorder: "our / This / bus / is / school"', 'options': ['This is school our bus.', 'This is our school bus.', 'Our school bus is this.'], 'correctIndex': 1},
      {'qID': 6, 'question': 'Reorder: "works / the / field / Father / in / paddy"', 'options': ['Father works in the paddy field.', 'Father in the paddy field works.', 'In the paddy field works Father.'], 'correctIndex': 0},
      {'qID': 7, 'question': 'Select the correct word for the picture:', 'options': ['Gate', 'Goat', 'Good'], 'correctIndex': 1, 'imagePath': 'assets/images/eng_q7.png'},
      {'qID': 8, 'question': 'Select the correct word for the picture:', 'options': ['Kettle', 'Cattle', 'Bottle'], 'correctIndex': 0, 'imagePath': 'assets/images/eng_q8.png'},
      {'qID': 9, 'question': 'Reorder: "the / is / pencil / My / table / on"', 'options': ['My table is on the pencil.', 'My pencil is on the table.', 'The pencil on is my table.'], 'correctIndex': 1},
      {'qID': 10, 'question': 'Reorder: "my / play / I / friends / with"', 'options': ['I play with my friends.', 'My friends play with I.', 'Play with my friends I.'], 'correctIndex': 0},
      {'qID': 11, 'question': 'What is the Sinhala meaning of "Sugar"?', 'options': ['ලුණු', 'සීනි', 'පිටි'], 'correctIndex': 1},
      {'qID': 12, 'question': 'What is the Sinhala meaning of "Rainbow"?', 'options': ['වැස්ස', 'දේදුන්න', 'අහස'], 'correctIndex': 1},
      {'qID': 13, 'question': 'Select the correct spelling:', 'options': ['Elephent', 'Elephant', 'Elefant'], 'correctIndex': 1, 'imagePath': 'assets/images/eng_q13.png'},
      {'qID': 14, 'question': 'Select the correct spelling:', 'options': ['Parot', 'Perrot', 'Parrot'], 'correctIndex': 2, 'imagePath': 'assets/images/eng_q14.png'},
      {'qID': 15, 'question': 'Sinhala meaning of "Who is shouting?"', 'options': ['කවුද කෑගසන්නේ?', 'ඇයි කෑගසන්නේ?', 'කවුද කතා කරන්නේ?'], 'correctIndex': 0},

    ];
    for (var q in engQuestions) { await engRef.collection('questions').add(q); }

    // Tamil Lesson
    DocumentReference tamilRef = _db.collection('lessons').doc('tamil_grade5_01');
    await tamilRef.set({
      'subject': 'Tamil',
      'topic': 'Tamil Practice 01',
      'description': 'Basic Tamil Phrases.',
      'content': "Select the correct answer.",
      'order': 1,
      'grade': 5,
    });

    // Clear old Tamil questions
    var oldTamQ = await tamilRef.collection('questions').get();
    for (var doc in oldTamQ.docs) { await doc.reference.delete(); }

    List<Map<String, dynamic>> tamilQuestions = [
      {'qID': 1, 'question': "'சந்தை' (සන්‍තෛ) යන දෙමළ වචනය සඳහා යෙදෙන සිංහල වචනය කුමක්ද?", 'options': ['පාසල', 'වෙළෙඳපොළ ', 'කඩය'], 'correctIndex': 1},
      {'qID': 2, 'question': '"කිරි බොන්න" යන්න දෙමළ බසින් කියන ආකාරය තෝරන්න.', 'options': ['பால் குடிக்க', 'தண்ணீர் குடிக்க', 'சோறு பபிதா'], 'correctIndex': 0},
      {'qID': 3, 'question': "'தாமரை பூ' (තාමරෙයි පූ) යනු කුමක්ද?", 'options': ['රෝස මල', 'නෙළුම් මල', 'පිච්ච මල'], 'correctIndex': 1},
      {'qID': 4, 'question': '"මට බෝලයක් දෙන්න" යන්න දෙමළ බසින් කියන ආකාරය තෝරන්න.', 'options': ['எனக்கு பந்து கொடுங்கள்', 'எனக்கு புத்தகம் கொடுங்கள்', 'நன் பந்து விளையாட'], 'correctIndex': 0},
      {'qID': 5, 'question': '"காகம் கறுப்பு நிறம்" (කාහම් කරුප්පු නිරම්) යන වාක්‍යයේ සිංහල අදහස කුමක්ද?', 'options': ['අහස නිල් පාටයි', 'කපුටා කළු පාටයි', 'මල රතු පාටයි'], 'correctIndex': 1},
      {'qID': 6, 'question': '"මට පොත දෙන්න" යන්න දෙමළ බසින් කියන ආකාරය තෝරන්න.', 'options': ['எனக்கு பேணா கொடுங்கள்', 'எனக்கு புத்தகம் கொடுங்கள்', 'எனக்கு தண்ணி தங்க'], 'correctIndex': 1},
    ];
    for (var q in tamilQuestions) { await tamilRef.collection('questions').add(q); }

    print("✅ English & Tamil Data Updated (Fixed IDs)");
  }
}