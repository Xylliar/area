import React from "react"
import { Search, X } from "lucide-react"
import { useGlobal } from "@/components/GlobalContext"

interface SearchBarProps {
  placeholder: string
  onSearch: (query: string) => void
  searchQuery: string
  onClear: () => void
}

export default function SearchBar({ placeholder, onSearch, searchQuery, onClear }: SearchBarProps) {
  const { isTextBigger } = useGlobal()

  return (
    <div className="relative mb-6">
      <input
        type="text"
        placeholder={placeholder}
        value={searchQuery}
        className={`w-full ${isTextBigger ? 'py-4 text-lg' : 'py-3 text-base'} pl-12 pr-10 text-gray-900 bg-gray-100 rounded-full focus:outline-none focus:ring-2 focus:ring-primary`}
        onChange={(e) => onSearch(e.target.value)}
      />
      <Search className="absolute left-4 top-1/2 transform -translate-y-1/2 text-gray-500" />
      {searchQuery && (
        <button
          onClick={onClear}
          className="absolute right-4 top-1/2 transform -translate-y-1/2 text-gray-500 hover:text-gray-700"
        >
          <X size={18} />
        </button>
      )}
    </div>
  )
}