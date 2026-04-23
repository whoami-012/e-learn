import { TeacherHeader } from './components/TeacherHeader';
import { SearchBar } from './components/SearchBar';
import { AIAssistantCard } from './components/AIAssistantCard';
import { FeaturedActionCard } from './components/FeaturedActionCard';
import { SectionTitle } from './components/SectionTitle';
import { CategoryChips } from './components/CategoryChips';
import { YourCourses } from './components/YourCourses';

export default function App() {
  return (
    <div className="min-h-screen bg-gray-50">
      <div className="max-w-md mx-auto bg-gray-50 min-h-screen pb-8">
        <TeacherHeader />
        <SearchBar />
        <AIAssistantCard />
        <FeaturedActionCard />
        <SectionTitle />
        <CategoryChips />
        <YourCourses />
      </div>
    </div>
  );
}