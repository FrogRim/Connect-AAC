//Static vocabulary data
import '../models/category.dart';
import '../models/vocabulary_item.dart';

class VocabularyData {
  // Get all categories
  static List<Category> getCategories() {
    return [
      const Category(
        id: 'emotions',
        name: '감정',
        iconName: 'sentiment_satisfied',
        description: '다양한 감정 표현',
      ),
      const Category(
        id: 'food',
        name: '음식/식사',
        iconName: 'restaurant',
        description: '음식과 식사 관련 표현',
      ),
      const Category(
        id: 'actions',
        name: '행동/정도',
        iconName: 'directions_run',
        description: '행동과 정도 표현',
      ),
      const Category(
        id: 'time',
        name: '시간',
        iconName: 'access_time',
        description: '시간 관련 표현',
      ),
      const Category(
        id: 'places',
        name: '장소/위치',
        iconName: 'place',
        description: '장소와 위치 표현',
      ),
      const Category(
        id: 'hygiene',
        name: '위생/의복',
        iconName: 'cleaning_services',
        description: '위생과 의복 관련 표현',
      ),
    ];
  }
  
  // Get all vocabulary items
  static List<VocabularyItem> getVocabularyItems() {
    return [
      // 감정 카테고리
      const VocabularyItem(
        id: 'happy',
        text: '행복해요',
        imageAsset: 'assets/images/emotions/happy.png',
        categoryId: 'emotions',
      ),
      const VocabularyItem(
        id: 'sad',
        text: '슬퍼요',
        imageAsset: 'assets/images/emotions/sad.png',
        categoryId: 'emotions',
      ),
      const VocabularyItem(
        id: 'angry',
        text: '화나요',
        imageAsset: 'assets/images/emotions/angry.png',
        categoryId: 'emotions',
      ),
      const VocabularyItem(
        id: 'scared',
        text: '무서워요',
        imageAsset: 'assets/images/emotions/scared.png',
        categoryId: 'emotions',
      ),
      const VocabularyItem(
        id: 'tired',
        text: '피곤해요',
        imageAsset: 'assets/images/emotions/tired.png',
        categoryId: 'emotions',
      ),
      const VocabularyItem(
        id: 'excited',
        text: '신나요',
        imageAsset: 'assets/images/emotions/excited.png',
        categoryId: 'emotions',
      ),
      
      // 음식/식사 카테고리
      const VocabularyItem(
        id: 'rice',
        text: '밥',
        imageAsset: 'assets/images/food/rice.png',
        categoryId: 'food',
      ),
      const VocabularyItem(
        id: 'water',
        text: '물',
        imageAsset: 'assets/images/food/water.png',
        categoryId: 'food',
      ),
      const VocabularyItem(
        id: 'soup',
        text: '국',
        imageAsset: 'assets/images/food/soup.png',
        categoryId: 'food',
      ),
      const VocabularyItem(
        id: 'fruit',
        text: '과일',
        imageAsset: 'assets/images/food/fruit.png',
        categoryId: 'food',
      ),
      const VocabularyItem(
        id: 'snack',
        text: '간식',
        imageAsset: 'assets/images/food/snack.png',
        categoryId: 'food',
      ),
      const VocabularyItem(
        id: 'milk',
        text: '우유',
        imageAsset: 'assets/images/food/milk.png',
        categoryId: 'food',
      ),
      
      // 행동/정도 카테고리
      const VocabularyItem(
        id: 'eat',
        text: '먹다',
        imageAsset: 'assets/images/actions/eat.png',
        categoryId: 'actions',
      ),
      const VocabularyItem(
        id: 'drink',
        text: '마시다',
        imageAsset: 'assets/images/actions/drink.png',
        categoryId: 'actions',
      ),
      const VocabularyItem(
        id: 'sleep',
        text: '자다',
        imageAsset: 'assets/images/actions/sleep.png',
        categoryId: 'actions',
      ),
      const VocabularyItem(
        id: 'play',
        text: '놀다',
        imageAsset: 'assets/images/actions/play.png',
        categoryId: 'actions',
      ),
      const VocabularyItem(
        id: 'walk',
        text: '걷다',
        imageAsset: 'assets/images/actions/walk.png',
        categoryId: 'actions',
      ),
      const VocabularyItem(
        id: 'run',
        text: '뛰다',
        imageAsset: 'assets/images/actions/run.png',
        categoryId: 'actions',
      ),
      
      // 시간 카테고리
      const VocabularyItem(
        id: 'morning',
        text: '아침',
        imageAsset: 'assets/images/time/morning.png',
        categoryId: 'time',
      ),
      const VocabularyItem(
        id: 'afternoon',
        text: '점심',
        imageAsset: 'assets/images/time/afternoon.png',
        categoryId: 'time',
      ),
      const VocabularyItem(
        id: 'evening',
        text: '저녁',
        imageAsset: 'assets/images/time/evening.png',
        categoryId: 'time',
      ),
      const VocabularyItem(
        id: 'now',
        text: '지금',
        imageAsset: 'assets/images/time/now.png',
        categoryId: 'time',
      ),
      const VocabularyItem(
        id: 'later',
        text: '나중에',
        imageAsset: 'assets/images/time/later.png',
        categoryId: 'time',
      ),
      const VocabularyItem(
        id: 'tomorrow',
        text: '내일',
        imageAsset: 'assets/images/time/tomorrow.png',
        categoryId: 'time',
      ),
      
      // 장소/위치 카테고리
      const VocabularyItem(
        id: 'home',
        text: '집',
        imageAsset: 'assets/images/places/home.png',
        categoryId: 'places',
      ),
      const VocabularyItem(
        id: 'school',
        text: '학교',
        imageAsset: 'assets/images/places/school.png',
        categoryId: 'places',
      ),
      const VocabularyItem(
        id: 'hospital',
        text: '병원',
        imageAsset: 'assets/images/places/hospital.png',
        categoryId: 'places',
      ),
      const VocabularyItem(
        id: 'bathroom',
        text: '화장실',
        imageAsset: 'assets/images/places/bathroom.png',
        categoryId: 'places',
      ),
      const VocabularyItem(
        id: 'outside',
        text: '밖',
        imageAsset: 'assets/images/places/outside.png',
        categoryId: 'places',
      ),
      const VocabularyItem(
        id: 'park',
        text: '공원',
        imageAsset: 'assets/images/places/park.png',
        categoryId: 'places',
      ),
      
      // 위생/의복 카테고리
      const VocabularyItem(
        id: 'wash',
        text: '씻다',
        imageAsset: 'assets/images/hygiene/wash.png',
        categoryId: 'hygiene',
      ),
      const VocabularyItem(
        id: 'brush',
        text: '양치하다',
        imageAsset: 'assets/images/hygiene/brush.png',
        categoryId: 'hygiene',
      ),
      const VocabularyItem(
        id: 'clothes',
        text: '옷',
        imageAsset: 'assets/images/hygiene/clothes.png',
        categoryId: 'hygiene',
      ),
      const VocabularyItem(
        id: 'shoes',
        text: '신발',
        imageAsset: 'assets/images/hygiene/shoes.png',
        categoryId: 'hygiene',
      ),
      const VocabularyItem(
        id: 'shower',
        text: '샤워하다',
        imageAsset: 'assets/images/hygiene/shower.png',
        categoryId: 'hygiene',
      ),
      const VocabularyItem(
        id: 'toilet',
        text: '화장실 가다',
        imageAsset: 'assets/images/hygiene/toilet.png',
        categoryId: 'hygiene',
      ),
    ];
  }
}