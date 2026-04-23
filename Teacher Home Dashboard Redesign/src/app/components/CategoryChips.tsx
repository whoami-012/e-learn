import { useState } from 'react';

const categories = [
  { id: 'all', label: 'All' },
  { id: 'courses', label: 'Courses' },
  { id: 'uploads', label: 'Uploads' },
  { id: 'scheduled', label: 'Scheduled' },
];

export function CategoryChips() {
  const [active, setActive] = useState('all');

  return (
    <div className="px-6 mb-6">
      <div className="flex gap-2 overflow-x-auto scrollbar-hide pb-2">
        {categories.map((category) => (
          <button
            key={category.id}
            onClick={() => setActive(category.id)}
            className={`flex-shrink-0 px-5 py-2 rounded-full font-medium text-sm transition-all duration-200 active:scale-95 ${
              active === category.id
                ? 'bg-gradient-to-r from-indigo-400 to-purple-400 text-white shadow-md shadow-indigo-200/50'
                : 'bg-white text-gray-600 border border-gray-200 hover:border-gray-300 shadow-sm shadow-black/5'
            }`}
          >
            {category.label}
          </button>
        ))}
      </div>
    </div>
  );
}
