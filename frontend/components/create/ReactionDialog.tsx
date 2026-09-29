"use client"

import { useState } from "react"
import { motion, AnimatePresence } from "framer-motion"
import Image from 'next/image'
import { PUBLIC_API_URL } from "@/lib/config"
import { Card, CardHeader, CardTitle, CardDescription, CardContent } from "@/components/ui/card"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle, DialogTrigger } from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Button } from "@/components/ui/button"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Badge } from "@/components/ui/badge"
import { ApiItem, ReactionInstance, Service } from "@/lib/types"

interface ReactionDialogProps {
  reactions: ApiItem[]
  selectedReactions: ReactionInstance[]
  setSelectedReactions: (reactions: ReactionInstance[]) => void
  servicesMap: Record<string, Service>
  isTextBigger: boolean
  isButtonBigger: boolean
}

export default function ReactionDialog({
  reactions,
  selectedReactions,
  setSelectedReactions,
  servicesMap,
  isTextBigger,
  isButtonBigger,
}: ReactionDialogProps) {
  const [isDialogOpen, setIsDialogOpen] = useState(false)
  const [searchQuery, setSearchQuery] = useState("")
  const [selectedItem, setSelectedItem] = useState<ApiItem | null>(null)

  const filteredReactions = reactions.filter((reaction) =>
    reaction.title.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const handleSelect = (reaction: ApiItem) => {
    const newReaction: ReactionInstance = {
      ...reaction,
      instanceId: `${reaction.id}-${Date.now()}`
    }
    setSelectedReactions([...selectedReactions, newReaction])
    setIsDialogOpen(false)
  }

  return (
    <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
      <DialogTrigger asChild>
        <Card className={`cursor-pointer transition-all duration-300 bg-gradient-to-br from-background to-accent/10 shadow-none ${isTextBigger ? "text-lg" : "text-base"}`}>
          <CardHeader>
            <CardTitle className={isTextBigger ? "text-lg" : "text-base"}>Then That</CardTitle>
            <CardDescription className={isTextBigger ? "text-lg" : "text-base"}>
              Select reactions to complete your applet
            </CardDescription>
          </CardHeader>
          <CardContent>
            {selectedReactions.length > 0 ? (
              <motion.div
                initial={{ opacity: 0 }}
                animate={{ opacity: 1 }}
                transition={{ duration: 0.3 }}
                className="flex flex-wrap gap-2"
              >
                {selectedReactions.map((reaction) => (
                  <Badge key={reaction.instanceId} variant="secondary">
                    {reaction.title}
                  </Badge>
                ))}
              </motion.div>
            ) : (
              <Button variant="outline" className={`w-full mt-auto ${isButtonBigger ? 'py-4 text-lg' : ''}`}>
                Select Reactions
              </Button>
            )}
          </CardContent>
        </Card>
      </DialogTrigger>
      <DialogContent className="sm:max-w-[800px]">
        <DialogHeader>
          <DialogTitle className={isTextBigger ? "text-lg" : "text-xl"}>
            Select Reactions
          </DialogTitle>
          <DialogDescription className={isTextBigger ? "text-base" : "text-sm"}>
            Choose reactions that will be triggered by your applet.
          </DialogDescription>
          <div className="mt-4">
            <Input
              placeholder="Search..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className={isTextBigger ? "text-lg" : "text-base"}
            />
          </div>
        </DialogHeader>
        <div className="grid grid-cols-[1.5fr,2fr] gap-4 py-4">
          <ScrollArea className="h-[400px] pr-4 border-r">
            {filteredReactions.map((reaction) => {
              const service = servicesMap[reaction.service_id]
              const backgroundColor = service?.color || '#000'
              const isSelected = selectedItem?.id === reaction.id
              const logoUrl = `${PUBLIC_API_URL}/services/${reaction.service_id}/icon`

              return (
                <motion.button
                  key={reaction.id}
                  className={`p-3 cursor-pointer rounded-md mb-2 flex items-center w-full text-left focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ${
                    isSelected ? "ring-2 ring-offset-2 ring-primary" : "hover:opacity-90"
                  }`}
                  onClick={() => setSelectedItem(reaction)}
                  whileTap={{ scale: 0.98 }}
                  style={{
                    backgroundColor: backgroundColor,
                    color: '#fff',
                  }}
                >
                  <Image
                    src={logoUrl}
                    alt={`${reaction.service_name} logo`}
                    width={24}
                    height={24}
                    className="mr-2"
                    unoptimized
                  />
                  <span>{reaction.title}</span>
                </motion.button>
              )
            })}
          </ScrollArea>
          <AnimatePresence mode="wait">
            {selectedItem && (
              <motion.div
                key={selectedItem.id}
                initial={{ opacity: 0, y: 20 }}
                animate={{ opacity: 1, y: 0 }}
                exit={{ opacity: 0, y: -20 }}
                transition={{ duration: 0.2 }}
                className="p-4 flex flex-col h-full"
              >
                <div className="flex items-center space-x-2 mb-4">
                  <h3 className={isTextBigger ? "font-semibold text-lg" : "font-semibold text-xl"}>{selectedItem.title}</h3>
                </div>
                <p className={isTextBigger ? "text-sm text-muted-foreground mb-4 flex-grow" : "text-base text-muted-foreground mb-4 flex-grow"}>{selectedItem.description}</p>
                <div className="flex flex-wrap gap-2 mb-4">
                  <Badge variant="secondary">{selectedItem.service_name}</Badge>
                </div>
                <Button
                  onClick={() => handleSelect(selectedItem)}
                  className={`w-full mt-auto focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 ${isButtonBigger ? 'py-4 text-lg' : ''}`}
                >
                  Add Reaction
                </Button>
              </motion.div>
            )}
          </AnimatePresence>
        </div>
      </DialogContent>
    </Dialog>
  )
}