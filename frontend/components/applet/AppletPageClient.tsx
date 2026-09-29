'use client'

import React, { useState, useEffect, useCallback } from "react"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"
import { ScrollArea } from "@/components/ui/scroll-area"
import { useToast } from "@/hooks/use-toast"
import { ToastAction } from "@/components/ui/toast"
import { updateApplet, deleteApplet } from "@/lib/api"
import { useGlobal } from "@/components/GlobalContext"
import { Applet } from "@/lib/types"
import Link from "next/link"
import SearchBar from "@/components/SearchBar"

function truncateText(text: string, maxLength: number): string {
  if (text.length <= maxLength) {
    return text;
  }
  return text.slice(0, maxLength) + '...';
}

interface AppletPageClientProps {
  initialApplets: Applet[]
  initialErrorMessage: string | null
}

export default function AppletPageClient({ initialApplets, initialErrorMessage }: AppletPageClientProps) {
  const [selectedApplet, setSelectedApplet] = useState<Applet | null>(null)
  const [errorMessage] = useState<string | null>(initialErrorMessage)
  const [applets, setApplets] = useState<Applet[]>(initialApplets)
  const { toast } = useToast()
  const { isTextBigger, isButtonBigger } = useGlobal()

  const [searchQuery, setSearchQuery] = useState("")
  const [filteredApplets, setFilteredApplets] = useState<Applet[]>(initialApplets)

  const handleSearch = useCallback((query: string) => {
    setSearchQuery(query)
    const lowercaseQuery = query.toLowerCase()
    const filtered: Applet[] = applets.filter((applet: Applet) =>
      applet.title.toLowerCase().includes(lowercaseQuery) ||
      (applet.description && applet.description.toLowerCase().includes(lowercaseQuery)) ||
      (applet.tags && applet.tags.some((tag: string) => tag.toLowerCase().includes(lowercaseQuery)))
    )
    setFilteredApplets(filtered)
  }, [applets])

  const handleClearSearch = useCallback(() => {
    setSearchQuery("")
    setFilteredApplets(applets)
  }, [applets])

  useEffect(() => {
    setFilteredApplets(applets)
  }, [applets])

  const handleButtonClick = async () => {
    if (!selectedApplet) return
    try {
      const response = await updateApplet(selectedApplet.id, !selectedApplet.active)

      if (!response) {
        toast({
          title: "Error",
          description: "Missing required service accounts. Please link required accounts in your profile.",
          variant: "destructive",
          action: (
            <Link href="/account">
              <ToastAction altText="Profile">Profile</ToastAction>
            </Link>
          ),
          duration: 5000,
        })
        return
      }

      const updatedApplet = { ...selectedApplet, active: !selectedApplet.active }
      setSelectedApplet(updatedApplet)
      setApplets(prevApplets => prevApplets.map(applet =>
        applet.id === selectedApplet.id ? updatedApplet : applet
      ))

      toast({
        title: "Success",
        description: `Applet ${response.active ? 'enabled' : 'disabled'} successfully.`,
        duration: 3000,
      })

    } catch (error) {
      console.error('Error updating applet status:', error)
      toast({
        title: "Error",
        description: "There was an error updating the applet status.",
        variant: "destructive",
        duration: 5000,
      })
    }
  }

  const handleDeleteClick = async () => {
    if (!selectedApplet) return
    try {
      await deleteApplet(selectedApplet.id)
      setApplets(prevApplets => prevApplets.filter(applet => applet.id !== selectedApplet.id))
      setSelectedApplet(null)
      toast({
        title: "Success",
        description: "Applet has been deleted successfully.",
        duration: 3000,
      })
    } catch (error) {
      console.error('Error deleting applet:', error)
      toast({
        title: "Error",
        description: "There was an error deleting the applet.",
        duration: 5000,
      })
    }
  }

  return (
    <div className="flex flex-col min-h-screen bg-background">
      <main className="flex-1 p-4 max-w-7xl mx-auto w-full mt-20">
        <h2 className={`font-bold mb-6 ${isTextBigger ? 'text-4xl' : 'text-3xl'}`}>My Applets</h2>
        <SearchBar
          placeholder="Search your applets"
          onSearch={handleSearch}
          searchQuery={searchQuery}
          onClear={handleClearSearch}
        />
        <div>
          {errorMessage ? (
            <div className={`text-center ${isTextBigger ? 'text-lg' : 'text-base'}`}>{errorMessage}</div>
          ) : (
            <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
              {filteredApplets.map((item, index) => (
                <div
                  key={index}
                  style={{ backgroundColor: item.color || "black" }}
                  className="text-white p-4 rounded-lg flex flex-col justify-between h-60 cursor-pointer transition-transform duration-500 ease-in-out hover:scale-105"
                  onClick={() => setSelectedApplet(item)}
                >
                  <div>
                    <h3 className={`font-bold mb-2 ${isTextBigger ? 'text-lg' : 'text-base'} flex items-center`}>
                      <span
                        className={`inline-block w-3 h-3 mr-2 ${item.active ? 'bg-green-500' : 'bg-red-500'}`}
                        style={{ borderRadius: '2px', flexShrink: 0 }}
                      ></span>
                      <span className="flex-1 flex items-center">{item.title}</span>
                    </h3>
                    {item.description && (
                      <p className={`mb-2 ${isTextBigger ? 'text-base' : 'text-sm'}`}>
                        {truncateText(item.description, 100)}
                      </p>
                    )}
                  </div>
                  <div className="mt-auto">
                    {item.tags && item.tags.length > 0 && (
                      <div className="flex flex-wrap gap-1">
                        {item.tags.slice(0, 3).map((tag: string, index: number) => (
                          <Badge key={index} variant="secondary" className={`text-xs ${isTextBigger ? 'py-1 px-2' : ''}`}>{tag}</Badge>
                        ))}
                        {item.tags.length > 3 && <Badge variant="secondary" className={`text-xs ${isTextBigger ? 'py-1 px-2' : ''}`}>+{item.tags.length - 3}</Badge>}
                      </div>
                    )}
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </main>
      {selectedApplet && (
        <Dialog open={selectedApplet !== null} onOpenChange={() => setSelectedApplet(null)}>
          <DialogContent className="sm:max-w-[550px] w-full max-h-[90vh] overflow-hidden flex flex-col p-0">
            <div style={{ backgroundColor: selectedApplet.color || "black" }} className="w-full h-32 flex items-center">
              <DialogHeader className="px-6 w-full">
                <DialogTitle className={`flex flex-col items-start text-white ${isTextBigger ? 'text-2xl' : 'text-xl'}`}>
                  <div className="flex items-center">
                    <span className="break-words whitespace-normal">{selectedApplet.title}</span>
                  </div>
                </DialogTitle>
              </DialogHeader>
            </div>
            <ScrollArea className="flex-grow">
              <div className="py-6 px-6">
                <p className="text-black font-bold">Description:</p>
                <p className={`text-gray-700 mb-4 ${isTextBigger ? 'text-base' : 'text-sm'}`}>{selectedApplet.description}</p>
                <div className="flex flex-wrap gap-2 mb-4">
                  <p>Tags: <br />
                    {Array.isArray(selectedApplet.tags) ? (
                      selectedApplet.tags.map((tag: string, index: number) => (
                        <Badge key={index} variant="secondary">{tag}</Badge>
                      ))
                    ) : (
                      <span>No tags provided</span>
                    )}
                  </p>
                </div>
              </div>
            </ScrollArea>
            <DialogFooter className="flex-shrink-0 px-6 py-4 bg-gray-50">
              <Button variant="outline" onClick={() => setSelectedApplet(null)}>Cancel</Button>
              <Button variant="outline" onClick={handleButtonClick} className={isButtonBigger ? 'py-4 text-lg' : ''}>
                {selectedApplet.active ? "Disable" : "Enable"}
              </Button>
              <Button variant="destructive" onClick={handleDeleteClick} className={`${isButtonBigger ? 'text-lg py-3 px-5' : 'text-base py-2 px-4'}`}>Delete</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}