"use client"

import { useState, useEffect, useMemo } from "react"
import { motion } from "framer-motion"
import { ArrowRight, Plus } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { useToast } from "@/hooks/use-toast"
import { getActionById, getReactionById, createApplet, createPublicApplet, isAdmin } from "@/lib/api"
import { useGlobal } from "@/components/GlobalContext"
import { ApiItem, ReactionInstance, Service } from "@/lib/types"
import ActionDialog from "@/components/create/ActionDialog"
import ReactionDialog from "@/components/create/ReactionDialog"
import AppletDetails from "@/components/create/AppletDetails"
import ActionConfiguration from "@/components/create/ActionConfiguration"
import ReactionConfiguration from "@/components/create/ReactionConfiguration"
import CreateAppletButton from "@/components/create/CreateAppletButton"
import { PUBLIC_API_URL as API_URL } from "@/lib/config"

interface AppletAutomationProps {
  initialActions: ApiItem[]
  initialReactions: ApiItem[]
}

export default function AppletAutomation({
  initialActions,
  initialReactions,
}: AppletAutomationProps) {
  const [selectedAction, setSelectedAction] = useState<ApiItem | null>(null)
  const [selectedReactions, setSelectedReactions] = useState<ReactionInstance[]>([])
  const [actionInputs, setActionInputs] = useState<Record<string, string>>({})
  const [reactionInputs, setReactionInputs] = useState<Record<string, Record<string, string>>>({})
  const [actionFields, setActionFields] = useState<Record<string, { regex: string; example: string }>>({})
  const [reactionFields, setReactionFields] = useState<Record<string, Record<string, { regex: string; example: string }>>>({})
  const [appletTitle, setAppletTitle] = useState("")
  const [appletDescription, setAppletDescription] = useState("")
  const [isLoading, setIsLoading] = useState(false)
  const [actionOutputs, setActionOutputs] = useState<string[]>([])
  const [services, setServices] = useState<Service[]>([])
  const { isTextBigger, isButtonBigger } = useGlobal()
  const { toast } = useToast()
  const [displayTags, setDisplayTags] = useState<string[]>([])
  const [isPublic, setIsPublic] = useState(false)
  const [isAdminUser, setIsAdminUser] = useState(false)

  useEffect(() => {
    if (selectedAction) {
      getActionById(selectedAction.id)
        .then((actionDetails) => {
          setActionFields(actionDetails.input_fields)
          setActionOutputs(actionDetails.output_fields)
        })
        .catch((error) => {
          console.error("Error fetching action details:", error)
          toast({
            title: "Error",
            description: "Failed to fetch action details. Please try again.",
            duration: 3000,
          })
        })
    }
  }, [selectedAction, toast])

  useEffect(() => {
    selectedReactions.forEach((reaction) => {
      getReactionById(reaction.id)
        .then((reactionDetails) => {
          if (reactionDetails) {
            setReactionFields((prev) => ({
              ...prev,
              [reaction.instanceId]: reactionDetails.input_fields,
            }))
          }
        })
        .catch((error) => {
          console.error("Error fetching reaction details:", error)
          toast({
            title: "Error",
            description: "Failed to fetch reaction details. Please try again.",
            duration: 3000,
          })
        })
    })
  }, [selectedReactions, toast])

  useEffect(() => {
    fetch(`${API_URL}/services`)
      .then((response) => response.json())
      .then((data) => {
        if (Array.isArray(data)) setServices(data)
      })
      .catch((error) => {
        console.error('Error fetching services:', error)
        toast({
          title: "Error",
          description: "Failed to fetch services. Please refresh the page.",
          duration: 3000,
        })
      })
  }, [toast])

  const servicesMap = useMemo(() => {
    const map: Record<string, Service> = {}
    services.forEach((service) => {
      map[service.id] = service
    })
    return map
  }, [services])

  useEffect(() => {
    const tags = new Set<string>()

    if (selectedAction) {
      tags.add(selectedAction.service_name.toLowerCase())
      tags.add(selectedAction.title.toLowerCase())
    }

    selectedReactions.forEach((reaction) => {
      tags.add(reaction.service_name.toLowerCase())
      tags.add(reaction.title.toLowerCase())
    })

    setDisplayTags(Array.from(tags))
  }, [selectedAction, selectedReactions])

  useEffect(() => {
    const checkAdmin = async () => {
      const adminStatus = await isAdmin()
      setIsAdminUser(adminStatus)
    }
    checkAdmin()
  }, [])

  const handleCreateApplet = async () => {
    if (selectedAction && selectedReactions.length > 0) {
      setIsLoading(true)
      try {
        const tags = new Set<string>()
        if (selectedAction) {
          tags.add(selectedAction.service_name.toLowerCase())
          tags.add(selectedAction.title.toLowerCase())
        }
        selectedReactions.forEach((reaction) => {
          tags.add(reaction.service_name.toLowerCase())
          tags.add(reaction.title.toLowerCase())
        })

        const tagsToSend = [...Array.from(tags), "custom"]

        const createFunction = isPublic && isAdminUser ? createPublicApplet : createApplet
        
        await createFunction(
          selectedAction.id,
          appletTitle,
          appletDescription,
          tagsToSend,
          actionInputs,
          selectedReactions.map((reaction) => ({
            reaction_id: reaction.id,
            reaction_inputs: reactionInputs[reaction.instanceId] || {}
          }))
        )
        toast({
          title: "Success",
          description: `Your applet has been created successfully as a ${isPublic ? 'public' : 'private'} applet.`,
          duration: 5000,
        })
      } catch (error) {
        console.error("Error creating applet:", error)
        toast({
          title: "Error",
          description: "There was an error creating the applet. Please try again.",
          duration: 5000,
        })
      } finally {
        setIsLoading(false)
      }
    }
  }

  const handleRemoveReaction = (instanceId: string) => {
    setSelectedReactions((prev) => prev.filter((reaction) => reaction.instanceId !== instanceId))
    setReactionInputs((prev) => {
      const newInputs = { ...prev }
      delete newInputs[instanceId]
      return newInputs
    })
    setReactionFields((prev) => {
      const newFields = { ...prev }
      delete newFields[instanceId]
      return newFields
    })
  }

  return (
    <div className="container mx-auto p-4 max-w-4xl mt-16">
      <h1 className={`text-4xl font-bold mb-20 text-center ${isTextBigger ? 'text-5xl' : ''}`}>Build Your Applet Automation</h1>
      <div className="grid md:grid-cols-2 gap-6 mb-8">
        <ActionDialog
          actions={initialActions}
          selectedAction={selectedAction}
          setSelectedAction={setSelectedAction}
          servicesMap={servicesMap}
          isTextBigger={isTextBigger}
          isButtonBigger={isButtonBigger}
        />
        <ReactionDialog
          reactions={initialReactions}
          selectedReactions={selectedReactions}
          setSelectedReactions={setSelectedReactions}
          servicesMap={servicesMap}
          isTextBigger={isTextBigger}
          isButtonBigger={isButtonBigger}
        />
      </div>

      <AppletDetails
        appletTitle={appletTitle}
        setAppletTitle={setAppletTitle}
        appletDescription={appletDescription}
        setAppletDescription={setAppletDescription}
        customTags={displayTags}
        setCustomTags={setDisplayTags}
        isTextBigger={isTextBigger}
        isPublic={isPublic}
        setIsPublic={setIsPublic}
        isAdminUser={isAdminUser}
      />

      {selectedAction && (
        <ActionConfiguration
          actionFields={actionFields}
          actionInputs={actionInputs}
          setActionInputs={setActionInputs}
          isTextBigger={isTextBigger}
        />
      )}

      {selectedReactions.map((reaction) => (
        <ReactionConfiguration
          key={reaction.instanceId}
          reaction={reaction}
          reactionFields={reactionFields[reaction.instanceId]}
          reactionInputs={reactionInputs[reaction.instanceId] || {}}
          setReactionInputs={(inputs) => setReactionInputs(prev => ({ ...prev, [reaction.instanceId]: inputs }))}
          actionOutputs={actionOutputs}
          onRemove={() => handleRemoveReaction(reaction.instanceId)}
          isTextBigger={isTextBigger}
        />
      ))}

      <motion.div
        className="flex justify-center items-center space-x-4 flex-wrap"
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: selectedAction && selectedReactions.length > 0 ? 1 : 0, y: selectedAction && selectedReactions.length > 0 ? 0 : 20 }}
        transition={{ duration: 0.3 }}
      >
        {selectedAction && (
          <div className="text-center flex flex-col items-center">
            <p className={`font-semibold mb-2 ${isTextBigger ? 'text-lg' : 'text-base'}`}>{selectedAction.title}</p>
            <Badge variant="outline">{selectedAction.service_name}</Badge>
          </div>
        )}
        {selectedAction && selectedReactions.length > 0 && <ArrowRight className="text-muted-foreground" />}
        {selectedReactions.map((reaction, index) => (
          <div key={reaction.instanceId} className="text-center flex flex-col items-center">
            {index > 0 && <Plus className="text-muted-foreground my-2" />}
            <p className={`font-semibold mb-2 ${isTextBigger ? 'text-lg' : 'text-base'}`}>{reaction.title}</p>
            <Badge variant="outline">{reaction.service_name}</Badge>
          </div>
        ))}
      </motion.div>

      {selectedAction && selectedReactions.length > 0 && (
        <CreateAppletButton
          isLoading={isLoading}
          onClick={handleCreateApplet}
          isButtonBigger={isButtonBigger}
        />
      )}
    </div>
  )
}