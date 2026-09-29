'use client'

import { useState, useEffect, useCallback } from "react"
import { Button } from "@/components/ui/button"
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogFooter } from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"
import { ScrollArea } from "@/components/ui/scroll-area"
import { useToast } from "@/hooks/use-toast"
import Image from 'next/image'
import { copyApplet, isAdmin, deletePublicApplet } from "@/lib/api"
import { Applet, Service } from "@/lib/types"
import { useGlobal } from "@/components/GlobalContext"
import { useRouter } from 'next/navigation'
import SearchBar from "@/components/SearchBar"
import { PUBLIC_API_URL as API_URL } from "@/lib/config"

interface AppletTabsProps {
  tabs: string[]
  activeTab: string
  onTabChange: (tab: string) => void
}

const AppletTabs = ({ tabs, activeTab, onTabChange }: AppletTabsProps) => {
  const { isTextBigger, isButtonBigger } = useGlobal()
  return (
    <div className="flex space-x-4 mb-6 overflow-x-auto">
      {tabs.map((tab) => (
        <button
          key={tab}
          className={`font-medium transition-colors whitespace-nowrap ${
            isButtonBigger ? 'px-6 py-3' : 'px-4 py-2'
          } ${isTextBigger ? 'text-base' : 'text-sm'} ${
            activeTab === tab
              ? "text-primary border-b-2 border-primary"
              : "text-muted-foreground hover:text-primary"
          }`}
          onClick={() => onTabChange(tab)}
        >
          {tab}
        </button>
      ))}
    </div>
  )
}

function isApplet(item: Applet | Service): item is Applet {
  return (item as Applet).title !== undefined
}

function truncateText(text: string, maxLength: number) {
  if (text.length <= maxLength) return text
  return text.slice(0, maxLength) + '...'
}

export default function Component() {
  const { isTextBigger, isButtonBigger } = useGlobal()
  const [selectedApplet, setSelectedApplet] = useState<Applet | null>(null)
  const [activeTab, setActiveTab] = useState("All")
  const [applets, setApplets] = useState<Applet[]>([])
  const [services, setServices] = useState<Service[]>([])
  const [filteredItems, setFilteredItems] = useState<(Applet | Service)[]>([])
  const [isLoading, setIsLoading] = useState(true)
  const [searchQuery, setSearchQuery] = useState("")
  const { toast } = useToast()
  const router = useRouter()
  const [isAdminUser, setIsAdminUser] = useState(false)

  const fetchData = useCallback(async () => {
    setIsLoading(true)
    try {
      const [appletsResponse, servicesResponse] = await Promise.all([
        fetch(`${API_URL}/applets`),
        fetch(`${API_URL}/services`)
      ])

      const appletsData = await appletsResponse.json()
      const servicesData = await servicesResponse.json()

      if (Array.isArray(appletsData)) setApplets(appletsData)
      if (Array.isArray(servicesData)) setServices(servicesData)

      setFilteredItems([...appletsData, ...servicesData])
    } catch (error) {
      console.error('Error fetching data:', error)
      toast({
        title: "Error",
        description: "There was an error fetching the data.",
        duration: 5000,
      })
    } finally {
      setIsLoading(false)
    }
  }, [toast])

  useEffect(() => {
    fetchData()
  }, [fetchData])

  useEffect(() => {
    const checkAdmin = async () => {
      const adminStatus = await isAdmin()
      setIsAdminUser(adminStatus)
    }
    checkAdmin()
  }, [])

  const handleSearch = useCallback((query: string) => {
    setSearchQuery(query)
    const lowercaseQuery = query.toLowerCase()
    let filtered: (Applet | Service)[] = []

    if (activeTab === "All" || activeTab === "Applets") {
      filtered = applets.filter(applet =>
        applet.title.toLowerCase().includes(lowercaseQuery) ||
        (applet.description && applet.description.toLowerCase().includes(lowercaseQuery)) ||
        (applet.tags && applet.tags.some(tag => tag.toLowerCase().includes(lowercaseQuery)))
      )
    }

    if (activeTab === "All" || activeTab === "Services") {
      const filteredServices = services.filter(service =>
        service.name.toLowerCase().includes(lowercaseQuery) ||
        (service.description && service.description.toLowerCase().includes(lowercaseQuery)) ||
        (service.tags && service.tags.some(tag => tag.toLowerCase().includes(lowercaseQuery)))
      )
      filtered = [...filtered, ...filteredServices]
    }

    setFilteredItems(filtered)
  }, [activeTab, applets, services])

  const handleTabChange = useCallback((tab: string) => {
    setActiveTab(tab)
    setSearchQuery("")
    if (tab === "All") {
      setFilteredItems([...applets, ...services])
    } else if (tab === "Applets") {
      setFilteredItems(applets)
    } else if (tab === "Services") {
      setFilteredItems(services)
    }
  }, [applets, services])

  const [isCopied, setIsCopied] = useState(false)

  const handleButtonClick = async () => {
    if (!selectedApplet || isCopied) return
    try {
      await copyApplet(selectedApplet.id)
      setIsCopied(true)
      toast({
        title: "Success",
        description: "Applet copied successfully!",
        duration: 3000,
      })
    } catch (error) {
      console.error('Error copying applet:', error)
      toast({
        title: "Error",
        description: "There was an error copying the applet.",
        duration: 5000,
      })
    }
  }

  const handleDelete = async (appletId: string) => {
    try {
      await deletePublicApplet(appletId)
      await fetchData()
      toast({
        title: "Success",
        description: "Applet deleted successfully!",
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

  const handleItemClick = useCallback((item: Applet | Service) => {
    if (isApplet(item)) {
      setSelectedApplet(item)
      setIsCopied(false)
    } else {
      router.push(`/applet/services?serviceid=${item.id}`)
    }
  }, [router])

  const handleClearSearch = useCallback(() => {
    setSearchQuery("")
    handleSearch("")
  }, [handleSearch])

  const buttonText = isCopied ? "Copied!" : "Use this applet"

  return (
    <div className="flex flex-col min-h-screen bg-background">
      <main className="flex-1 p-4 max-w-7xl mx-auto w-full mt-20">
        <h2 className={`font-bold mb-6 ${isTextBigger ? 'text-4xl' : 'text-3xl'}`}>Explore</h2>
        <AppletTabs
          tabs={["All", "Applets", "Services"]}
          activeTab={activeTab}
          onTabChange={handleTabChange}
        />
        <SearchBar
          placeholder="Search Applets or Services"
          onSearch={handleSearch}
          searchQuery={searchQuery}
          onClear={handleClearSearch}
        />
        {isLoading ? (
          <div className={`text-center ${isTextBigger ? 'text-lg' : 'text-base'}`}>Loading...</div>
        ) : filteredItems.length === 0 ? (
          <div className={`text-center ${isTextBigger ? 'text-lg' : 'text-base'}`}>No items found</div>
        ) : (
          <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4">
            {filteredItems.map((item, index) => {
              const src = `${API_URL}/services/${item.id}/icon`
              const isSvg = src.endsWith('.svg')
              return (
                <div
                  key={index}
                  style={{ backgroundColor: item.color || "black" }}
                  className="text-white p-4 rounded-lg flex flex-col justify-between h-60 cursor-pointer transition-transform duration-500 ease-in-out hover:scale-105"
                  onClick={() => handleItemClick(item)}
                >
                  <div>
                    <h3 className={`font-bold mb-2 ${isTextBigger ? 'text-lg' : 'text-base'}`}>
                      {isApplet(item) ? item.title : item.name}
                    </h3>
                    {!isApplet(item) && (
                      <Image
                        src={src}
                        alt={`${isApplet(item) ? item.title : item.name} icon`}
                        width={48}
                        height={48}
                        className="object-contain mt-2"
                        unoptimized={isSvg}
                      />
                    )}
                  </div>
                  <div className="mt-auto">
                    {item.description && (
                      <p className={`mb-2 ${isTextBigger ? 'text-base' : 'text-sm'}`}>{truncateText(item.description, 150)}</p>
                    )}
                    {item.tags && item.tags.length > 0 && (
                      <div className="flex flex-wrap gap-1">
                        {item.tags.slice(0, 3).map((tag, index) => (
                          <Badge key={index} variant="secondary" className={`text-xs ${isTextBigger ? 'py-1 px-2' : ''}`}>{tag}</Badge>
                        ))}
                        {item.tags.length > 3 && <Badge variant="secondary" className={`text-xs ${isTextBigger ? 'py-1 px-2' : ''}`}>+{item.tags.length - 3}</Badge>}
                      </div>
                    )}
                  </div>
                </div>
              )
            })}
          </div>
        )}
      </main>
      {selectedApplet && (
        <Dialog open={selectedApplet !== null} onOpenChange={() => setSelectedApplet(null)}>
          <DialogContent className="sm:max-w-[550px] w-full max-h-[90vh] overflow-hidden flex flex-col p-0">
            <div style={{ backgroundColor: selectedApplet?.color || "black" }} className="w-full h-32 flex items-center">
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
                <p className={`text-gray-700 mb-4 ${isTextBigger ? 'text-base' : 'text-sm'}`}>{selectedApplet?.description}</p>
                <div className="mb-4">
                  <span className="text-black font-bold">Tags:</span>
                  <div className="mt-2 flex flex-wrap gap-2">
                    {Array.isArray(selectedApplet?.tags) ? (
                      selectedApplet.tags.map((tag, index) => (
                        <Badge key={index} variant="secondary">{tag}</Badge>
                      ))
                    ) : (
                      <span>No tags provided</span>
                    )}
                  </div>
                </div>
              </div>
            </ScrollArea>
            <DialogFooter className="flex-shrink-0 px-6 py-4 bg-gray-50">
              <Button variant="outline" onClick={() => setSelectedApplet(null)}>Cancel</Button>
              {isAdminUser && (
                <Button
                  variant="destructive"
                  onClick={() => {
                    handleDelete(selectedApplet!.id)
                    setSelectedApplet(null)
                  }}
                >
                  Delete Public Applet
                </Button>
              )}
              <Button onClick={handleButtonClick} className={`${isButtonBigger ? 'text-lg py-3 px-5' : 'text-base py-2 px-4'}`}>{buttonText}</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      )}
    </div>
  )
}
