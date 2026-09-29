'use client'

import React, { useState, KeyboardEvent, ChangeEvent } from 'react'
import { X } from 'lucide-react'
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"

interface TagInputProps {
  tags: string[]
  setTags: React.Dispatch<React.SetStateAction<string[]>>
}

export default function TagInput({ tags, setTags }: TagInputProps) {
  const [input, setInput] = useState('')

  const handleInputChange = (e: ChangeEvent<HTMLInputElement>) => {
    setInput(e.target.value)
  }

  const handleInputKeyDown = (e: KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && input) {
      e.preventDefault()
      if (!tags.includes(input.trim())) {
        setTags([...tags, input.trim()])
        setInput('')
      }
    }
  }

  const removeTag = (tagToRemove: string) => {
    setTags(tags.filter(tag => tag !== tagToRemove))
  }

  return (
    <div className="space-y-2">
      <div className="flex flex-wrap gap-1.5">  {/* Reduced gap */}
        {tags.map(tag => (
          <div 
            key={tag} 
            className="flex items-center bg-gray-100 hover:bg-gray-200 text-gray-700 px-1.5 py-0.5 rounded-full text-sm transition-colors"
          >
            <span className="mr-1 text-xs">{tag}</span>
            <Button
              variant="ghost"
              size="sm"
              className="p-0 h-3 w-3 hover:bg-transparent"
              onClick={() => removeTag(tag)}
            >
              <X className="h-2.5 w-2.5" />
            </Button>
          </div>
        ))}
      </div>
      <Input
        type="text"
        value={input}
        onChange={handleInputChange}
        onKeyDown={handleInputKeyDown}
        placeholder="Type a tag and press Enter"
        className="mt-2"
      />
    </div>
  )
}