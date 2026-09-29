'use client'

import { useState } from "react"
import { ScrollArea } from "@/components/ui/scroll-area"
import { ChevronDown, ChevronUp } from "lucide-react"
import { useGlobal } from "@/components/GlobalContext"
import { ActionReaction } from "@/lib/types"
import ActionReactionCard from '@/components/services/aReaCard'
import ActionReactionDialog from '@/components/services/aReaDialog'

export default function ActionReactionList({ items, title, type, serviceid, serviceColor }: {
  items: ActionReaction[]
  title: string
  serviceid: string
  type: 'actions' | 'reactions'
  serviceColor: string
}) {
  const [expandedSection, setExpandedSection] = useState<'actions' | 'reactions' | null>(null)
  const [selectedItem, setSelectedItem] = useState<ActionReaction | null>(null)
  const { isTextBigger } = useGlobal()

  return (
    <div className="mt-12 px-4">
      <div
        className="flex items-center justify-between cursor-pointer group p-4 hover:bg-accent/50 rounded-lg transition-all duration-200"
        onClick={() => setExpandedSection(expandedSection === type ? null : type)}
      >
        <div className="flex items-center space-x-3">
          <h2 className={`${isTextBigger ? 'text-3xl' : 'text-2xl'} font-bold tracking-tight`}>
            {title}
            <span className="ml-2 text-muted-foreground text-sm font-normal">
              ({items.length})
            </span>
          </h2>
        </div>
        <div className="transform transition-transform duration-200 group-hover:scale-110">
          {expandedSection === type ? <ChevronUp /> : <ChevronDown />}
        </div>
      </div>
      {expandedSection === type && (
        <div className="mt-6 transition-all duration-300 ease-in-out">
          <ScrollArea className="h-[70vh] pr-4">
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {items.map((item: ActionReaction) => (
                <ActionReactionCard
                  key={item.id}
                  item={item}
                  serviceColor={serviceColor}
                  serviceid={serviceid}
                  onClick={() => setSelectedItem(item)}
                />
              ))}
            </div>
          </ScrollArea>
        </div>
      )}
      <ActionReactionDialog
        selectedItem={selectedItem}
        onClose={() => setSelectedItem(null)}
      />
    </div>
  )
}